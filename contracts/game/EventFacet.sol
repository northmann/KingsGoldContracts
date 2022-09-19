// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/AppStorageExtensions.sol";
import "../libraries/StructureEventExtensions.sol";
import "../libraries/LibMeta.sol";
import "../general/ReentrancyGuard.sol";
import "./GameAccess.sol";
import {LibRoles} from "../libraries/LibRoles.sol";



contract EventFacet is Game, ReentrancyGuard, GameAccess {
    using AppStorageExtensions for AppStorage;
    using StructureEventExtensions for StructureEvent;


    struct Args {
        EventAction eventActionId;
        AssetType assetTypeId;
        uint256 provinceId;
        uint256 multiplier;
        uint256 rounds;
        uint256 hero;
    }

    function pack(uint256 high, uint256 low) public pure returns (uint256 packed) {
        return (uint256(high) << 128) | uint256(low);
    }


    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    


    // --------------------------------------------------------------
    // Public Functions
    // --------------------------------------------------------------
    
    function createStructureEvent(Args calldata args) external nonReentrant {
        _createEvent(msg.sender, args);
    }


    function payAndCompleteStructureEvent(uint256 eventId) external nonReentrant {
        _payForTimeStructureEvent(eventId);
        _completeStructureEvent(eventId);
    }

    /// When a user has paid for time, this method gets called.
    function payForTimeStructureEvent(uint256 _eventId) external nonReentrant
    {
        _payForTimeStructureEvent(_eventId);
    }

    // Complete a structure event
    // This is called when the event is complete, cancelled.
    function completeStructureEvent(uint256 _eventId) external nonReentrant
    {
        _completeStructureEvent(_eventId);
    }

    // --------------------------------------------------------------
    // Internal Functions
    // --------------------------------------------------------------


    function _createEvent(address userAddress, Args calldata args) internal {
        // check that the hero exist and is controlled by user.
        console.log("createStructureEvent start");

        Province storage province = s.provinces[args.provinceId]; // Struct from mapping

        console.log("createStructureEvent create Event");

        uint256 eventId = pack(args.provinceId, s.provinceStructureEventList[args.provinceId].length);

        StructureEvent memory e;

        e.id = eventId;
        e.eventActionId = args.eventActionId;
        e.assetTypeId = args.assetTypeId;
        e.provinceId = args.provinceId;
        e.multiplier = args.multiplier;
        e.rounds = args.rounds;
        e.hero = args.hero;
        e.userAddress = userAddress;
        e.creationTime = block.timestamp;
        e.state = EventState.Active;

        AssetAction memory assetAction = s.getAssetAction(args.assetTypeId, args.eventActionId);

        console.log("createStructure calculate cost");

        e.calculatedCost = s.calculateCost(args.multiplier, args.rounds, assetAction.cost);
        e.calculatedReward = s.calculateCost(args.multiplier, args.rounds, assetAction.reward);

        console.log("createStructure check manpower");
        require(e.calculatedCost.manPower <= province.populationAvailable, "not enough population");

        province.populationAvailable = province.populationAvailable - e.calculatedCost.manPower;

        console.log("createStructure spend commodities Event");
        // Spend the resouces on the behalf of the user
        s.spendCommodities(e.calculatedCost);

        console.log("createStructure add event");

        User storage user = s.users[userAddress];
        uint256 index = user.structureEventCount + 1; // Get the index of the event. Zero index is empty!
        user.structureEventCount = index; // Increase the count of events.

        s.structureEvents[eventId] = e; 

        s.provinceActiveStructureEventList[args.provinceId].push(eventId);
        s.provinceCheckpoint[args.provinceId].activeStructureEvents = block.timestamp;

        s.provinceStructureEventList[args.provinceId].push(eventId);
        s.provinceCheckpoint[args.provinceId].structureEvents = block.timestamp;

        s.userActiveStructureEventList[msg.sender].push(eventId);
        s.userCheckpoint[msg.sender].activeStructureEvents = block.timestamp;

        s.userStructureEventList[msg.sender].push(eventId);
        s.userCheckpoint[msg.sender].structureEvents = block.timestamp;
    }


        function _payForTimeStructureEvent(uint256 _eventId) internal
    {
        StructureEvent storage structureEvent = s.getStructureEvent(_eventId);
        require(structureEvent.state == EventState.Active, "Illegal state");

        structureEvent.state = EventState.PaidFor;
        structureEvent.calculatedCost.time = 0;
    }

    function _completeStructureEvent(uint256 _eventId) internal
    {
        StructureEvent storage structureEvent = s.getStructureEvent(_eventId);
        require(structureEvent.state != EventState.Completed && structureEvent.state != EventState.Cancelled, "Illegal state");
        //require(block.timestamp >= structureEvent.creationTime + structureEvent.calculatedCost.time,"The time has not expired" );

        // Add structure to province
        _updateStructureCount(structureEvent);

        // Update the population
        Province storage province = s.getProvince(structureEvent.provinceId);
        structureEvent.updatePopulation(s, province, structureEvent.calculatedCost);

        if(block.timestamp >= structureEvent.creationTime + structureEvent.calculatedCost.time)
            structureEvent.state = EventState.Completed;
        else 
            structureEvent.state = EventState.Cancelled;
        
    }

    function _updateStructureCount(StructureEvent storage structureEvent) internal {
        uint256 count = (structureEvent.multiplier * structureEvent.rounds);
        // Reduce the number of building buildt.
        count =  structureEvent.reducedAmountOnTimePassed(count, structureEvent.calculatedCost);
        
        if(count > 0) {
            Structure storage structure = s.addStructureSafe(structureEvent.provinceId, structureEvent.assetTypeId);
            structure.available = structure.available + count;
            structure.total = structure.total + count;
        }
    }

    

}



//     // Perform timed transitions. Be sure to mention
//     // this modifier first, otherwise the guards
//     // will not take the new stage into account.
//     modifier timeExpired() virtual {
//         require(
//             block.timestamp >= creationTime + timeRequired,
//             "The time has not expired"
//         );
//         _;
//     }

//     /// The cost of the time to complete the event with rounds and multipliers.
//     function priceForTime() external view virtual override returns (uint256) {
//         // Check if the time needed to complete the event is over, then just return zero cost.
//         if (
//             (block.timestamp - creationTime) >=
//             (timeRequired * rounds * multiplier)
//         ) return 0;

//         uint256 baseCost = province.world().baseGoldCost();
//         console.log("BaseCost: ", baseCost);
//         console.log("multiplier: ", multiplier);
//         console.log("goldForTime: ", goldForTime);
//         console.log("rounds: ", rounds);
//         uint256 basePrice = ((goldForTime * baseCost) / 1e18);
//         console.log("basePrice: ", basePrice);
//         uint256 totalCost = multiplier * rounds * basePrice;
//         console.log("totalCost: ", totalCost);

//         uint256 reducedCost = reducedAmountOnTimePassed(totalCost);
//         console.log("reducedCost: ", totalCost);

//         // uint256 factor = ((block.timestamp - creationTime) * 1e18) / (timeRequired * rounds * multiplier);
//         // uint256 reducedCost = totalCost - ((totalCost * factor) / 1e18);

//         return reducedCost;
//     }

//     /// When a user has paid for time, this method gets called.
//     function payForTime()
//         public
//         virtual
//         override
//         onlyProvince
//         isState(State.Active)
//     {}

//     // Callback funcation from above after the event has been paid for.
//     function paidForTime()
//         public
//         virtual
//         override
//         onlyProvince
//         isState(State.Active)
//     {
//         state = State.PaidFor;
//         timeRequired = 0;
//     }

//     function complete()
//         public
//         virtual
//         override
//         timeExpired
//         onlyProvince
//         notState(State.Completed)
//         notState(State.Cancelled)
//     {
//         // Update event lists on the province
//         uint256 eventIndex = province.findActiveEventIndex(address(this));
//         if(eventIndex != NO_INDEX) {
//             province.archiveEvent(eventIndex);
//         }

//         // Update the population
//         updatePopulation();

//         state = State.Completed;
//     }

//     function cancel()
//         public
//         virtual
//         override
//         onlyProvince
//         notState(State.Minted)
//         notState(State.Completed)
//         notState(State.Cancelled)
//     {
//         // E.g;
//         // Calculate penalty
//         updatePopulation();
//         state = State.Cancelled;
//     }

//     function penalizeAmount(uint256 _amount)
//         internal
//         view
//         virtual
//         returns (uint256)
//     {
//         uint256 reducedAmount = reducedAmountOnTimePassed(_amount);
//         uint256 amountLeft = (_amount - reducedAmount);
//         amountLeft = ((amountLeft * penalty) / 1e18);

//         return amountLeft;
//     }

//     function reducedAmountOnTimePassed(uint256 _amount)
//         internal
//         view
//         returns (uint256)
//     {
//         if ((block.timestamp - creationTime) >= (timeRequired * rounds))
//             return 0;

//         uint256 factor = ((block.timestamp - creationTime) * 1e18) /
//             (timeRequired * rounds);
//         uint256 reducedAmount = (_amount - ((_amount * factor) / 1e18));

//         return reducedAmount;
//     }

//     function updatePopulation() internal virtual {
//         //assert(attrition <= 1e18); // Cannot be more than 100%
//         // Calc mamPower Attrition

//         uint256 attritionCost = ((manPower * attrition) / baseUnit); // Calculate the percentage of the attrition.
//         uint256 reducedAmount = reducedAmountOnTimePassed(attritionCost);
//         attritionCost = attritionCost - reducedAmount; // Attrition increases over time.
//         uint256 manPowerLeft = manPower - attritionCost;

//         province.setPopulationAvailable(
//             province.populationAvailable() + manPowerLeft
//         );
//         province.setPopulationTotal(province.populationTotal() - attritionCost);
//     }

//     function getAttributes()
//         public
//         view
//         returns (
//             State EventState,
//             IProvince Province,
//             uint256 CreationTime,
//             uint256 TimeRequired,
//             uint256 GoldForTime,
//             uint256 Attrition,
//             address Hero,
//             uint256 TimeBaseCost,
//             uint256 GoldForTimeBaseCost,
//             uint256 FoodBaseCost,
//             uint256 Multiplier,
//             uint256 Penalty,
//             uint256 Rounds,
//             uint256 ManPower,
//             uint256 FoodAmount,
//             uint256 WoodAmount,
//             uint256 RockAmount,
//             uint256 IronAmount,
//             address Receiver
//         )
//     {
//         return (
//             state,
//             province,
//             creationTime,
//             timeRequired,
//             goldForTime,
//             attrition,
//             hero,
//             timeBaseCost,
//             goldForTimeBaseCost,
//             foodBaseCost,
//             multiplier,
//             penalty,
//             rounds,
//             manPower,
//             foodAmount,
//             woodAmount,
//             rockAmount,
//             ironAmount,
//             receiver
//         );
//     }
// }
