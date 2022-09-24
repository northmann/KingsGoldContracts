// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/ProvinceExtensions.sol";
import "../libraries/ArmyExtensions.sol";
import "../libraries/LibRoles.sol";
import "../libraries/Math.sol";
import "../general/InternalCallGuard.sol";
import "../general/Game.sol";
import "./AccessControlFacet.sol";
import "./GameAccess.sol";

contract ArmyFacet is Game, GameAccess, InternalCallGuard {
    using AppStorageExtensions for AppStorage;
    using ProvinceExtensions for Province;
    using ArmyExtensions for Army;

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function getArmy(uint256 _sourceArmyId) external view returns (Army memory army) {
        army = s.armies[_sourceArmyId];
    }

    function getProvinceArmies(uint256 provinceId) external view returns (Army[] memory armies) {
        uint256[] memory armyList = s.provinceArmies[provinceId];

        armies = new Army[](armyList.length);
        for (uint256 i = 0; i < armyList.length; i++) {
            armies[i] = s.armies[armyList[i]];
        }
    }

    function getArmyUnits(uint256 _sourceArmyId) external view returns (ArmyUnit[] memory units) {
        Army storage army = s.armies[_sourceArmyId];
        units = army.units;
    }

    // --------------------------------------------------------------
    // Public Functions
    // --------------------------------------------------------------

    function createArmy(uint256 _provinceId, ArmyUnit[] calldata _units) public requiredRole(LibRoles.MINTER_ROLE) {
        Army storage army = _createArmy(_provinceId, msgSender());

        for (uint256 i = 0; i < _units.length; i++) army.units.push(_units[i]);
    }

    function updateArmy(uint256 _sourceArmyId, ArmyUnit[] calldata units) public requiredRole(LibRoles.MINTER_ROLE) {
        Army storage army = s.armies[_sourceArmyId];

        delete army.units;

        for (uint256 i = 0; i < units.length; i++) army.units.push(units[i]);
    }

    function updateGarrison(uint256 _provinceId, ArmyUnit[] calldata _units) public requiredRole(LibRoles.MINTER_ROLE) {
        Army storage army = _getGarrison(_provinceId);

        delete army.units;

        for (uint256 i = 0; i < _units.length; i++) army.units.push(_units[i]);
    }

    function moveArmy(uint256 _sourceArmyId, uint256 _destinationId) public {
        Army storage army = s.armies[_sourceArmyId];
        require(msgSender() == army.owner, "ArmyFacet: Not owner");
        require(army.provinceId == _destinationId, "ArmyFacet: Army already moved or moving to that province");

        if (army.state == ArmyState.Moving) {
            if (block.timestamp >= army.endTime) {
                _removeDepartureMove(army);
                _setDepartureMove(army);
                _setDestinationMove(army, _destinationId);
            } else {
                _removeDestinationMove(army);
                _setDestinationMove(army, _destinationId);
            }
        } else {
            // Army other state
            _setDepartureMove(army);
            _setDestinationMove(army, _destinationId);
        }
    }

    function mergeArmy(uint256 _sourceArmyId, uint256 _targetArmyId) public {
        Army storage army = s.armies[_sourceArmyId];
        Army storage targetArmy = s.armies[_targetArmyId];

        require(msgSender() == army.owner, "ArmyFacet: Not army owner");
        require(army.provinceId == targetArmy.provinceId, "ArmyFacet: Not in same province");
        require(army.state == ArmyState.Idle, "ArmyFacet: Army not idle");
        require(targetArmy.state == ArmyState.Idle, "ArmyFacet: Target Army not idle");

        for (uint256 i = 0; i < army.units.length; i++) {

            ArmyUnitType armyUnitTypeId = army.units[i].armyUnitTypeId;
            
            ArmyUnit storage targetUnit = targetArmy.getUnit(armyUnitTypeId);
            
            uint256 addAmount = army.units[i].amount;
            uint256 shares = 0;
            
            if(targetUnit.amount == 0)
                shares = Math.sqrt(addAmount);
            else {
                shares = (addAmount * targetUnit.shares) / (targetUnit.amount + addAmount);
            }

            targetUnit.amount += addAmount;
            targetUnit.shares += shares; // Total shares of the unit

            ArmyUnit storage sharesUnit = s.armyShares[army.owner][_targetArmyId].getUnit(armyUnitTypeId);
            sharesUnit.amount += addAmount;
            sharesUnit.shares += shares; // The users shares of the unit
        }          

        _removeArmy(army);
    }

    function splitArmy(uint256 _sourceArmyId, ArmyUnit[] calldata _units) public {
        Army storage army = s.armies[_sourceArmyId];

        //require(msgSender() == army.owner, "ArmyFacet: Not army owner");
        require(army.state == ArmyState.Idle, "ArmyFacet: Army not idle");

        Army storage newArmy = _createArmy(army.provinceId, msgSender());

        for (uint256 i = 0; i < _units.length; i++) {
            ArmyUnitType armyUnitTypeId = _units[i].armyUnitTypeId;

            ArmyUnit storage callUnit = army.getUnit(armyUnitTypeId);
            ArmyUnit storage sharesUnit = s.armyShares[msgSender()][_sourceArmyId].getUnit(armyUnitTypeId);

            if(callUnit.shares == 0) continue;
            require(sharesUnit.shares >= callUnit.shares, "ArmyFacet: Not enough shares");

            ArmyUnit storage armyUnit = army.getUnit(armyUnitTypeId);
            
            uint256 amount = (callUnit.shares * armyUnit.amount) / armyUnit.shares;

            require(amount <= armyUnit.amount, "ArmyFacet: Not enough amount");

            armyUnit.amount -= amount;
            armyUnit.shares -= callUnit.shares;

            sharesUnit.shares -= callUnit.shares;
            sharesUnit.amount -= amount;

             ArmyUnit storage newUnit = newArmy.getUnit(armyUnitTypeId);
             newUnit.amount += amount;
             newUnit.shares = 0;
        }
    }

    function produceSoldier(uint256 eventId) public onlyInternalCall {
        _produceUnit(eventId, ArmyUnitType.Soldier);
    }

    function produceArcher(uint256 eventId) public onlyInternalCall {
        _produceUnit(eventId, ArmyUnitType.Archer);
    }

    function produceKnight(uint256 eventId) public onlyInternalCall {
        _produceUnit(eventId, ArmyUnitType.Knight);
    }

    function produceCatapult(uint256 eventId) public onlyInternalCall {
        _produceUnit(eventId, ArmyUnitType.Catapult);
    }

    // --------------------------------------------------------------
    // Private Functions
    // --------------------------------------------------------------

    function _produceUnit(uint256 eventId, ArmyUnitType typeId) internal {
        StructureEvent storage ev = s.structureEvents[eventId];

        Army storage garrison = _getGarrison(ev.provinceId);

        ArmyUnit storage unit = garrison.getUnit(typeId);

        unit.amount += ev.calculatedReward.amount;
    }

    function _getGarrison(uint256 provinceId) internal returns (Army storage garrison) {
        Province storage province = s.provinces[provinceId];
        if (province.garrisonId == 0) {
            garrison = _createArmy(provinceId, msgSender());
        } else garrison = s.armies[province.garrisonId];
    }

    function _createArmy(uint256 _provinceId, address _owner) internal returns (Army storage army) {
        s.armyCount++; // Army Index starts with 1

        army = s.armies[s.armyCount];
        army.id = s.armyCount;
        army.state = ArmyState.Idle;
        army.owner = _owner;

        army.provinceId = _provinceId;
        army.departureProvinceId = 0;

        army.provinceArmyIndex = s.provinceArmies[_provinceId].length;
        s.provinceArmies[_provinceId].push(s.armyCount);

        army.ownerArmyIndex = s.userArmies[_owner].length;
        s.userArmies[_owner].push(s.armyCount);
    }

    function _removeArmy(Army storage army) internal {
        // Remove army from departure province
        _removeDepartureMove(army);
        _removeDestinationMove(army);

        // Remove army from owner
        _removeArmyFromOwner(army);

        delete s.armies[army.id]; // Delete army
    }

    function _setDestinationMove(Army storage army, uint256 _destinationId) internal {
        army.provinceId = _destinationId;
        army.provinceArmyIndex = s.provinceArmies[_destinationId].length;
        s.provinceArmies[_destinationId].push(army.id);
    }

    function _setDepartureMove(Army storage army) internal {
        _removeDestinationMove(army); // Remove from main list

        army.departureArmyIndex = s.departureArmies[army.provinceId].length;
        army.departureProvinceId = army.provinceId;
        s.departureArmies[army.provinceId].push(army.id);
    }

    function _removeDepartureMove(Army storage army) internal {
        if(army.departureProvinceId == 0) return;

        uint256 lastArmyId = _removeArmyFromArray(s.departureArmies[army.departureProvinceId], army.departureArmyIndex);
        s.armies[lastArmyId].departureArmyIndex = army.departureArmyIndex;
        army.departureProvinceId = 0;
    }

    function _removeDestinationMove(Army storage army) internal {
        // Army arrived at destination and is now idle
        // Remove army from departure province
        uint256 lastArmyId = _removeArmyFromArray(s.provinceArmies[army.provinceId], army.provinceArmyIndex);
        s.armies[lastArmyId].provinceArmyIndex = army.provinceArmyIndex;
    }

    function _removeArmyFromOwner(Army storage army) internal {
        uint256 lastArmyId = _removeArmyFromArray(s.userArmies[army.owner], army.ownerArmyIndex);
        s.armies[lastArmyId].ownerArmyIndex = army.ownerArmyIndex;
    }

    function _removeArmyFromArray(uint256[] storage armyArray, uint256 armyIndex) internal returns (uint256) {
        if (armyArray.length > 0) {
            uint256 lastArmyId = armyArray[armyArray.length - 1];
            armyArray[armyIndex] = lastArmyId;
            armyArray.pop();
            return lastArmyId;
        }
        return 0;
    }


}
