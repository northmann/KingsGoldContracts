// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";
import "./AppStorageExtensions.sol";
import "./ProvinceExtensions.sol";
import "./ResourceFactorExtensions.sol";
import "./LibMeta.sol";

library StructureEventExtensions {
    using AppStorageExtensions for AppStorage;
    using StructureEventExtensions for StructureEvent;
    using ProvinceExtensions for Province;
    using ResourceFactorExtensions for ResourceFactor;
    

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function isState(StructureEvent storage self, EventState _state) internal view {
        require(_state == self.state, "Illegal state");
    }

    function hasTimeExpired(StructureEvent storage self) internal view returns (bool) {
        return (block.timestamp - self.creationTime) >= (self.calculatedCost.time * self.rounds);
    }

    function reducedAmountOnTimePassed(StructureEvent storage self, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        if(self.hasTimeExpired() || _amount == 0) 
            return _amount;

        uint256 factor = ((block.timestamp - self.creationTime) * 1e18) /(self.calculatedCost.time * self.rounds);

        uint256 reducedAmount = (_amount * factor) / 1e18;

        return reducedAmount;
    }

    function reducedRewardOnTimePassed(StructureEvent storage self, ResourceFactor memory _reward)
        internal
        view
        returns (ResourceFactor memory _result)
    {

        if(self.hasTimeExpired()) {
            _result = self.calculatedReward;
        } else {
            _result.manPower = self.reducedAmountOnTimePassed(_reward.manPower);
            _result.food = self.reducedAmountOnTimePassed(_reward.food);
            _result.wood = self.reducedAmountOnTimePassed(_reward.wood);
            _result.rock = self.reducedAmountOnTimePassed(_reward.rock);
            _result.iron = self.reducedAmountOnTimePassed(_reward.iron);
        }
    }


    // --------------------------------------------------------------
    // Write Functions
    // --------------------------------------------------------------

    function updateStructureCount(StructureEvent storage self, AppStorage storage s) internal {
        uint256 count = (self.multiplier * self.rounds);
        // Reduce the number of building buildt.
        count =  self.reducedAmountOnTimePassed(count);
        
        if(count > 0) {
            Structure storage structure = s.addStructureSafe(self.provinceId, self.assetTypeId);
            structure.available = structure.available + count;
            structure.total = structure.total + count;
            self.calculatedReward.amount = count;
        }
    }


    function produceStructureEvent(StructureEvent storage self, AppStorage storage s) internal {

        ResourceFactor memory reward =  self.reducedRewardOnTimePassed(self.calculatedReward);

        Province storage province = s.getProvince(self.provinceId);

        // Add the reward to the province
        if(reward.manPower > 0) {
            province.populationAvailable = province.populationAvailable + reward.manPower;
            province.populationTotal = province.populationTotal + reward.manPower; 
        }

        // Add the reward to the province alliance, owner, and vassal
        province.addReward(reward); 

        self.calculatedReward = reward;
    }   

    function dismantleStructureEvent(StructureEvent storage self, AppStorage storage s) internal {
        uint256 count = (self.multiplier * self.rounds);
        // Reduce the number of building buildt.
        uint amount =  self.reducedAmountOnTimePassed(count);
        
        if(amount > 0) {
            Structure storage structure = s.getStructure(self.provinceId, self.assetTypeId);
            structure.available = structure.available - amount;
            structure.total = structure.total - amount;
            self.calculatedReward.amount = amount;


            Province storage province = s.getProvince(self.provinceId);

            if(amount != count) {
                // Recalculate the resource factor, if canceled early.
                // This way the player gets the correct amount of resources back.
                // The amount of resources is reduced by the amount of structure dismantle.
                AssetAction memory assetAction = s.getAssetAction(self.assetTypeId, self.eventActionId);
                ResourceFactor memory reward = assetAction.reward.calculateCost(1, amount, s.baseSettings);
                self.calculatedReward = reward; // Change the reward size
                province.addReward(reward);                
            }
            else {
                // Add the reward to the province alliance, owner, and vassal
                province.addReward(self.calculatedReward);
            }
        }

    }


    function burnStructureEvent(StructureEvent storage self, AppStorage storage s) internal {
        uint256 count = (self.multiplier * self.rounds);
        // Reduce the number of building buildt.
        uint amount =  self.reducedAmountOnTimePassed(count);
        
        if(amount > 0) {
            Structure storage structure = s.getStructure(self.provinceId, self.assetTypeId);
            structure.available = structure.available - amount;
            structure.total = structure.total - amount;
            self.calculatedReward.amount = amount;
        }
    }
    

    function updatePopulation(StructureEvent storage self, Province storage _province) internal {
        assert(self.calculatedCost.attrition <= 1e18); // Cannot be more than 100%
        //Calc mamPower Attrition

        // _cost.manPowerAttrition is the calculated cost in manPower attrition
        uint256 attritionAmount = self.reducedAmountOnTimePassed(self.calculatedCost.manPowerAttrition); // Attrition increases over time.
        
        _province.populationAvailable = _province.populationAvailable + self.calculatedCost.manPower - attritionAmount; // Add manPower back to the province and reduce by attrition
        _province.populationTotal = _province.populationTotal - attritionAmount; // Total population decreases over time because of attrition.
    }



}