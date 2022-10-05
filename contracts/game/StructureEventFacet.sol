// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/AppStorage.sol";
import "../libraries/AppStorageExtensions.sol";
import "../libraries/StructureEventExtensions.sol";
import "../libraries/ResourceFactorExtensions.sol";
import "../libraries/LibMeta.sol";
import "../libraries/InternalCall.sol";
import "../general/ReentrancyGuard.sol";
import "../general/Game.sol";
import "./GameAccess.sol";
import {LibRoles} from "../libraries/LibRoles.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


contract StructureEventFacet is Game, ReentrancyGuard, GameAccess {
    using AppStorageExtensions for AppStorage;
    using StructureEventExtensions for StructureEvent;
    using ResourceFactorExtensions for ResourceFactor;
    using EnumerableSet for EnumerableSet.UintSet;

    struct Args {
        EventAction eventActionId;
        AssetType assetTypeId;
        uint256 provinceId;
        uint256 multiplier;
        uint256 rounds;
        uint256 hero;
    }

    // function pack(uint256 high, uint256 low) public pure returns (uint256 packed) {
    //     return (uint256(high) << 128) | uint256(low);
    // }

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    // --------------------------------------------------------------
    // Public Functions
    // --------------------------------------------------------------

    function createStructureEvent(Args calldata args) external nonReentrant {
        _createStructureEvent(args);
    }

    function payAndCompleteStructureEvent(uint256 eventId) external payable nonReentrant {
        _payForTimeStructureEvent(eventId);
        _completeStructureEvent(eventId);
    }

    /// When a user has paid for time, this method gets called.
    function payForTimeStructureEvent(uint256 _eventId) external payable nonReentrant {
        _payForTimeStructureEvent(_eventId);
    }

    // Complete a structure event
    // This is called when the event is complete, cancelled.
    function completeStructureEvent(uint256 _eventId) external nonReentrant {
        _completeStructureEvent(_eventId);
    }

    // --------------------------------------------------------------
    // Internal Functions
    // --------------------------------------------------------------

    function _createStructureEvent(Args calldata args) internal {
        // check that the hero exist and is controlled by user.
        Province storage province = s.provinces[args.provinceId]; // Struct from mapping
        
        s.structureEventCount++;
        uint256 eventId = s.structureEventCount;

        StructureEvent memory e;

        e.id = eventId;
        e.eventActionId = args.eventActionId;
        e.assetTypeId = args.assetTypeId;
        e.provinceId = args.provinceId;
        e.multiplier = args.multiplier;
        e.rounds = args.rounds;
        e.hero = args.hero;
        e.creationTime = block.timestamp;
        e.state = EventState.Active;

        AssetAction memory assetAction = s.getAssetAction(args.assetTypeId, args.eventActionId);

        e.calculatedCost = assetAction.cost.calculateCost(args.multiplier, args.rounds, s.baseSettings);
        e.calculatedReward = assetAction.reward.calculateCost(args.multiplier, args.rounds, s.baseSettings);

        require(e.calculatedCost.manPower <= province.populationAvailable, "not enough population");
        province.populationAvailable = province.populationAvailable - e.calculatedCost.manPower;

        // Spend the resouces on the behalf of the user (msg.sender)
        s.spendCommodities(e.calculatedCost);

        // Add the event to the list of events
        s.provinceActiveStructureTaskList[args.provinceId].add(eventId);

        s.structureEvents[eventId] = e;

        // Remove available structures
        if(args.eventActionId != EventAction.Build) {
            s.structureEvents[eventId].decreaseAvailableStructure(s);
        }
    }

    function _payForTimeStructureEvent(uint256 _eventId) internal {
        StructureEvent storage structureEvent = s.getStructureEvent(_eventId);
        require(structureEvent.state == EventState.Active, "Illegal state");

        uint256 price = structureEvent.calculatedCost.goldForTime;

        if (!s.baseSettings.gold.transferFrom(LibMeta.msgSender(), address(this), price))
            revert("KingsGold transfer failed from sender to treasury.");

        structureEvent.state = EventState.PaidFor;
        structureEvent.calculatedCost.time = 0;
    }

    function _completeStructureEvent(uint256 _eventId) internal {
        StructureEvent storage e = s.getStructureEvent(_eventId);
        require(e.state != EventState.Completed && e.state != EventState.Cancelled, "Illegal state");

        AssetAction memory assetAction = s.getAssetAction(e.assetTypeId, e.eventActionId);

        bytes memory callData =  abi.encodeWithSignature(assetAction.method, _eventId);
        InternalCall.delegateCall(callData);

        // Update the population
        Province storage province = s.getProvince(e.provinceId);
        e.updatePopulation(province);

        if(e.eventActionId != EventAction.Build) {
            e.increaseAvailableStructure(s);
        }

        e.state = e.hasTimeExpired() ? EventState.Completed : EventState.Cancelled;
        e.endTime = block.timestamp;

        // Remove the event from the active list
        s.provinceActiveStructureTaskList[e.provinceId].remove(e.id);

        // Add the event to the completed list
        s.provinceStructureTaskList[e.provinceId].add(e.id);
    }

}
