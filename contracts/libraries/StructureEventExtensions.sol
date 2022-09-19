// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";
import "./LibMeta.sol";

library StructureEventExtensions {
    using StructureEventExtensions for StructureEvent;
    

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function isState(StructureEvent storage self, EventState _state) internal view {
        require(_state == self.state, "Illegal state");
    }

    function reducedAmountOnTimePassed(StructureEvent storage self, uint256 _amount, ResourceFactor memory _cost)
        internal
        view
        returns (uint256)
    {
        if ((block.timestamp - self.creationTime) >= (_cost.time * self.rounds))
            return _amount;

        uint256 factor = ((block.timestamp - self.creationTime) * 1e18) /(_cost.time * self.rounds);

        uint256 reducedAmount = (_amount * factor) / 1e18;

        return reducedAmount;
    }

    // --------------------------------------------------------------
    // Write Functions
    // --------------------------------------------------------------


    function updatePopulation(StructureEvent storage self, AppStorage storage s, Province storage _province, ResourceFactor memory _cost) internal {
        assert(_cost.attrition <= 1e18); // Cannot be more than 100%
        //Calc mamPower Attrition

        // _cost.manPowerAttrition is the calculated cost in manPower attrition
        uint256 attritionAmount = self.reducedAmountOnTimePassed(_cost.manPowerAttrition, _cost); // Attrition increases over time.
        
        _province.populationAvailable = _province.populationAvailable + _cost.manPower - attritionAmount; // Add manPower back to the province and reduce by attrition
        _province.populationTotal = _province.populationTotal - attritionAmount; // Total population decreases over time because of attrition.

        // Update the province check point
        s.provinceCheckpoint[_province.id].province = block.timestamp;
    }

}