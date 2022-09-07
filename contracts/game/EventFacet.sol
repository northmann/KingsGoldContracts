// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/LibAppStorageExtensions.sol";
import "../libraries/LibEventExtensions.sol";
import "../libraries/LibMeta.sol";
import "../general/ReentrancyGuard.sol";
import "./GameAccess.sol";
import {LibRoles} from "../libraries/LibRoles.sol";



contract EventFacet is Game, ReentrancyGuard, GameAccess {
    using LibAppStorageExtensions for AppStorage;
    using LibEventExtensions for StructureEvent;


    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    


    // --------------------------------------------------------------
    // Public Functions
    // --------------------------------------------------------------

    /// When a user has paid for time, this method gets called.
    function payForTimeStructureEvent(uint256 _eventId)  public
    {
        StructureEvent storage structureEvent = s.getStructureEvent(_eventId);
        require(structureEvent.state == EventState.Active, "Illegal state");

        structureEvent.state = EventState.PaidFor;
        structureEvent.calculatedCost.time = 0;
    }

    function completeStructureEvent(uint256 _eventId)
        public
        nonReentrant
    {
        StructureEvent storage structureEvent = s.getStructureEvent(_eventId);
        require(structureEvent.state != EventState.Completed && structureEvent.state != EventState.Cancelled, "Illegal state");
        require(block.timestamp >= structureEvent.creationTime + structureEvent.calculatedCost.time,"The time has not expired" );

        console.log("Add Structure to province");

        Province storage province = s.getProvince(structureEvent.provinceId);

        // Add structure to province
        uint256 count = (structureEvent.multiplier * structureEvent.rounds);

        Structure storage structure = s.addStructureSafe(structureEvent.provinceId, structureEvent.assetTypeId);
        structure.available = structure.available + count;
        structure.total = structure.total + count;

        console.log("Update the population");
        // Update the population
        structureEvent.updatePopulation(s, province, structureEvent.calculatedCost);

        structureEvent.state = EventState.Completed;
    }

    function cancelStructureEvent(uint256 _eventId)
        public
    {
        StructureEvent storage structureEvent = s.getStructureEvent(_eventId);
        require(structureEvent.state != EventState.Completed 
                && structureEvent.state != EventState.Cancelled
                , "Illegal state");
        require(block.timestamp >= structureEvent.creationTime + structureEvent.calculatedCost.time,"The time has not expired" );

        // Add structure to province

        uint256 count = (structureEvent.multiplier * structureEvent.rounds);
        // Reduce the number of building buildt.
        count =  count - structureEvent.reducedAmountOnTimePassed(count, structureEvent.calculatedCost);
        
        if(count > 0) {
            Structure storage structure = s.addStructureSafe(structureEvent.provinceId, structureEvent.assetTypeId);
            structure.available = structure.available + count;
            structure.total = structure.total + count;
        }

        // E.g;
        // Calculate penalty
        Province storage province = s.getProvince(structureEvent.provinceId);
        structureEvent.updatePopulation(s, province, structureEvent.calculatedCost);

        structureEvent.state = EventState.Cancelled;
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
