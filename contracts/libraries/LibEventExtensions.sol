// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";
import "./LibMeta.sol";

library LibEventExtensions {
    using LibEventExtensions for StructureEvent;
    
    function isState(StructureEvent storage self, EventState _state) public view {
        require(_state == self.state, "Illegal state");
    }

    function reducedAmountOnTimePassed(StructureEvent storage self, uint256 _amount, ResourceFactor memory _cost)
        internal
        view
        returns (uint256)
    {
        if ((block.timestamp - self.creationTime) >= (_cost.time * self.rounds))
            return 0;

        uint256 factor = ((block.timestamp - self.creationTime) * 1e18) /(_cost.time * self.rounds);

        uint256 reducedAmount = (_amount - ((_amount * factor) / 1e18));

        return reducedAmount;
    }

    function updatePopulation(StructureEvent storage self, Province storage _province, ResourceFactor memory _cost) internal {
        assert(_cost.attrition <= 1e18); // Cannot be more than 100%
        //Calc mamPower Attrition

        uint256 reducedAmount =  self.reducedAmountOnTimePassed(_cost.manPowerAttrition, _cost);
        _cost.manPowerAttrition = _cost.manPowerAttrition - reducedAmount; // Attrition increases over time.
        uint256 manPowerLeft = _cost.manPower - _cost.manPowerAttrition;

        _province.populationAvailable = _province.populationAvailable + manPowerLeft;
        _province.populationTotal = _province.populationTotal + manPowerLeft;

    }

}