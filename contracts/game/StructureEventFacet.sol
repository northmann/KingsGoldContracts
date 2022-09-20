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

        uint256 eventId = pack(args.provinceId, s.provinceStructureEventList[args.provinceId].length);

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

        e.provinceActiveEventIndex = s.provinceActiveStructureEventList[args.provinceId].length;
        s.provinceActiveStructureEventList[args.provinceId].push(eventId);

        s.structureEvents[eventId] = e;

        // Remove available structures
        s.structureEvents[eventId].decreaseAvailableStructure(s);


    }

    function _payForTimeStructureEvent(uint256 _eventId) internal {
        StructureEvent storage structureEvent = s.getStructureEvent(_eventId);
        require(structureEvent.state == EventState.Active, "Illegal state");

        uint256 price = structureEvent.calculatedCost.goldForTime;
        console.log("payForTimeStructureEvent price: %s", price);

        if (!s.baseSettings.gold.transferFrom(LibMeta.msgSender(), address(this), price))
            revert("KingsGold transfer failed from sender to treasury.");

        structureEvent.state = EventState.PaidFor;
        structureEvent.calculatedCost.time = 0;
    }

    function _completeStructureEvent(uint256 _eventId) internal {
        StructureEvent storage e = s.getStructureEvent(_eventId);
        require(e.state != EventState.Completed && e.state != EventState.Cancelled, "Illegal state");

        if (e.eventActionId == EventAction.Build) {
            // Add structure to province
            e.build(s);
        } else if (e.eventActionId == EventAction.Produce) {
            e.produce(s);
            //_completeUpgradeStructureEvent(_eventId);
        } else if (e.eventActionId == EventAction.Dismantle) {
            e.dismantle(s);
        } else if (e.eventActionId == EventAction.Burn) {
            e.burn(s);
        }

        // Update the population
        Province storage province = s.getProvince(e.provinceId);
        e.updatePopulation(province);

        e.increaseAvailableStructure(s);


        e.state = e.hasTimeExpired() ? EventState.Completed : EventState.Cancelled;
        e.endTime = block.timestamp;

        // Remove the event from the active list
        e.moveActiveStructureEvent(s);
    }

}