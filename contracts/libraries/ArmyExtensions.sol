// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";

library ArmyExtensions {

    // uint256[] constant public armyUnitDefencePriority = [
    //     0, // None
    //     1, // Militia
    //     2, // Soldier
    //     3, // Knight
    //     4, // Archer
    //     5, // Catapult
    //     6 // Last
    // ];

    

    function getUnit(AppStorage storage self, uint256 armyId, ArmyUnitType armyUnitTypeId) internal view returns (ArmyUnit storage) {
        return self.armyUnits[armyId][armyUnitTypeId];
        // for (uint256 i = 0; i < self.units.length; i++) 
        //     if (self.units[i].armyUnitTypeId == armyUnitTypeId) 
        //         return self.units[i];

        // self.units.push(ArmyUnit(armyUnitTypeId, 0, 0)); // add new unit

        // return self.units[self.units.length-1]; // return new unit from storage
    }


}


