// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";

library ArmyExtensions {



    function getUnit(Army storage self, ArmyUnitType armyUnitTypeId) internal returns (ArmyUnit storage) {
        for (uint256 i = 0; i < self.units.length; i++) 
            if (self.units[i].armyUnitTypeId == armyUnitTypeId) 
                return self.units[i];

        self.units.push(ArmyUnit(armyUnitTypeId, 0, 0)); // add new unit

        return self.units[self.units.length-1]; // return new unit from storage
    }


}