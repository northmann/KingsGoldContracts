// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";

library ResourceFactorExtensions {
    using ResourceFactorExtensions for ResourceFactor;

    function calculateCost(ResourceFactor memory _cost, uint256 _multiplier, uint256 _rounds, BaseSettings memory _baseSettings) internal pure returns (ResourceFactor memory result) {
        // Rule: Everything cost manPower, manPower always cost food and time.
        uint256 oneHour = 60 * 60;

        uint256 baseTime = _cost.time > 0 ? _cost.time : oneHour; // 1 hour if no time is set
        result.time = baseTime * _rounds; // Change in manPower could alter this.
        result.manPower = _multiplier * _cost.manPower; // The _cost in manPower

        uint256 baseGoldCostForTime = _cost.goldForTime > 0 ? _cost.goldForTime : (_cost.manPower * baseTime * _baseSettings.goldForTimeBaseCost) / oneHour;
        result.goldForTime = baseGoldCostForTime * _rounds * _multiplier;

        uint256 baseFoodCost = _cost.food > 0 ? _cost.food : (_cost.manPower * baseTime * _baseSettings.baseUnit)  / oneHour;
        result.food = baseFoodCost * _rounds * _multiplier;

        result.attrition = _cost.attrition; // The _cost in attrition
        result.manPowerAttrition = ((result.manPower * result.attrition) / 1e18); // The _cost in manPowerAttrition
        result.penalty = _cost.penalty; // The _cost in penalty

        result.wood = _rounds * _multiplier * ((_cost.wood * _baseSettings.baseUnit) / 1e18);
        result.rock = _rounds * _multiplier * ((_cost.rock * _baseSettings.baseUnit) / 1e18);
        result.iron = _rounds * _multiplier * ((_cost.iron * _baseSettings.baseUnit) / 1e18);

        result.amount = _rounds * _multiplier;
    }

    function rewardFee(uint256 _amount, uint256 _fee, uint256 _baseUnit) internal pure returns (uint256) {
        return (_amount * _fee) / _baseUnit;
    }
    
    function fee(ResourceFactor memory self, uint256 _fee) internal pure returns (ResourceFactor memory _result) {
        uint256 _baseUnit = 1e18;
        _result.food = rewardFee(self.food, _fee, _baseUnit);
        _result.wood = rewardFee(self.wood, _fee, _baseUnit);
        _result.rock = rewardFee(self.rock, _fee, _baseUnit);
        _result.iron = rewardFee(self.iron, _fee, _baseUnit);
        _result.amount = rewardFee(self.amount, _fee, _baseUnit);
    }

    function sub(ResourceFactor memory self, ResourceFactor memory _spend) internal pure returns (ResourceFactor memory _result) {
        _result.food = self.food - _spend.food;
        _result.wood = self.wood - _spend.wood;
        _result.rock = self.rock - _spend.rock;
        _result.iron = self.iron - _spend.iron;
        _result.amount = self.amount - _spend.amount;
    }

}
