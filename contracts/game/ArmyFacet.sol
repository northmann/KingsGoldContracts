// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/StructureEventExtensions.sol";
import "../libraries/ProvinceExtensions.sol";
import "../libraries/ArmyExtensions.sol";
import "../general/InternalCallGuard.sol";

contract ArmyFacet is Game, InternalCallGuard {
    using AppStorageExtensions for AppStorage;
    using ProvinceExtensions for Province;
    using ArmyExtensions for Army;

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function getArmy(uint256 _armyId) external view returns (Army memory army) {
        AppStorage storage s = LibAppStorage.appStorage();
        army = s.armies[_armyId];
    }

    // --------------------------------------------------------------
    // Public Functions
    // --------------------------------------------------------------

    function produceSoldier(uint256 eventId) public onlyInternalCall {
        produceUnit(eventId, ArmyUnitType.Soldier);
    }

    function produceArcher(uint256 eventId) public onlyInternalCall {
        produceUnit(eventId, ArmyUnitType.Archer);
    }

    function produceKnight(uint256 eventId) public onlyInternalCall {
        produceUnit(eventId, ArmyUnitType.Knight);
    }

    function produceCatapult(uint256 eventId) public onlyInternalCall {
        produceUnit(eventId, ArmyUnitType.Catapult);
    }


    function produceUnit(uint256 eventId, ArmyUnitType typeId) internal {
        StructureEvent storage ev = s.structureEvents[eventId];

        Army storage garrison = s.armies[ev.provinceId];

        ArmyUnit storage unit = garrison.getUnit(typeId);

        unit.amount = unit.amount + ev.calculatedReward.amount;   
    }


}
