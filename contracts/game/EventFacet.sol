// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/AppStorageExtensions.sol";
import "../libraries/StructureEventExtensions.sol";
import "../libraries/ResourceFactorExtensions.sol";
import "../libraries/LibMeta.sol";
import "../general/ReentrancyGuard.sol";
import "./GameAccess.sol";
import {LibRoles} from "../libraries/LibRoles.sol";



contract StructureEventFacet is Game, ReentrancyGuard, GameAccess {
    using AppStorageExtensions for AppStorage;
    using StructureEventExtensions for StructureEvent;
    using ResourceFactorExtensions for ResourceFactor;


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
        _createStructureEvent(msg.sender, args);
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


    function _createStructureEvent(address userAddress, Args calldata args) internal {
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

        e.calculatedCost =  assetAction.cost.calculateCost(args.multiplier, args.rounds, s.baseSettings);
        e.calculatedReward = assetAction.reward.calculateCost(args.multiplier, args.rounds, s.baseSettings);

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

        if(structureEvent.eventActionId == EventAction.Build) {
            // Add structure to province
            structureEvent.updateStructureCount(s);
        } else 

        if(structureEvent.eventActionId == EventAction.Produce) {
            structureEvent.produceStructureEvent(s);
            //_completeUpgradeStructureEvent(_eventId);
        } else 

        if(structureEvent.eventActionId == EventAction.Dismantle) {
            structureEvent.dismantleStructureEvent(s);
        } else 

        if(structureEvent.eventActionId == EventAction.Burn) {
            structureEvent.burnStructureEvent(s);
        } 
            

        // Update the population
        Province storage province = s.getProvince(structureEvent.provinceId);
        structureEvent.updatePopulation(province);

        if(block.timestamp >= structureEvent.creationTime + structureEvent.calculatedCost.time)
            structureEvent.state = EventState.Completed;
        else 
            structureEvent.state = EventState.Cancelled;

        structureEvent.endTime = block.timestamp;
    }


}
