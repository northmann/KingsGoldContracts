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
        return block.timestamp >= (self.creationTime + self.calculatedCost.time);
    }

    function reducedOnTimePassed(StructureEvent storage self, uint256 _amount)
        internal
        view
        returns (uint256)
    {
        if(self.hasTimeExpired() || _amount == 0) 
            return _amount;

        uint256 factor = ((block.timestamp - self.creationTime) * 1e18) / self.calculatedCost.time;

        uint256 reducedAmount = (_amount * factor) / 1e18;

        return reducedAmount;
    }



    // --------------------------------------------------------------
    // Write Functions
    // --------------------------------------------------------------

    function build(StructureEvent storage self, AppStorage storage s) internal returns(uint256 amount) {
        amount = self.calculatedReward.amount;
        
        if(!self.hasTimeExpired()) {
            amount = self.reducedOnTimePassed(amount);

            uint256 rest = self.calculatedReward.amount - amount;

            // Repay the user for commodities that was not buildt.
            AssetAction memory assetAction = s.getAssetAction(self.assetTypeId, self.eventActionId);
            
            // Calculate the resources of the remaining buildings not buildt.
            ResourceFactor memory reward = assetAction.cost.calculateCost(1, rest, s.baseSettings);

            // Remove penalty from the remaining resources.
            reward = reward.sub(reward.fee(reward.penalty));

            // Add the remaining resources to the user.
            self.calculatedReward.food = reward.food;
            self.calculatedReward.wood = reward.wood;
            self.calculatedReward.rock = reward.rock;
            self.calculatedReward.iron = reward.iron;
            self.calculatedReward.amount = amount;

            Province storage province = s.getProvince(self.provinceId);
            province.addReward(self.calculatedReward, false); // Not taxed because the user did not produce anything.
        }

        Structure storage structure = s.addStructureSafe(self.provinceId, self.assetTypeId);
        structure.available = structure.available + amount;
        structure.total = structure.total + amount;

    }


    function produce(StructureEvent storage self, AppStorage storage s) internal {

        if(!self.hasTimeExpired()) {
            ResourceFactor memory reward = self.calculatedReward;
            reward.manPower = self.reducedOnTimePassed(reward.manPower);
            reward.food = self.reducedOnTimePassed(reward.food);
            reward.wood = self.reducedOnTimePassed(reward.wood);
            reward.rock = self.reducedOnTimePassed(reward.rock);
            reward.iron = self.reducedOnTimePassed(reward.iron);

            self.calculatedReward = reward.sub(reward.fee(reward.penalty));
        }

        // Add the reward to the province alliance, owner, and vassal
        Province storage province = s.getProvince(self.provinceId);
        province.addReward(self.calculatedReward, true); // Taxed because the user did produce something.
    }   

    function dismantle(StructureEvent storage self, AppStorage storage s) internal  returns(uint256 amount) {
        amount = self.calculatedReward.amount;

        if(!self.hasTimeExpired()) {
            amount = self.reducedOnTimePassed(amount);

            AssetAction memory assetAction = s.getAssetAction(self.assetTypeId, self.eventActionId);
            ResourceFactor memory reward = assetAction.reward.calculateCost(1, amount, s.baseSettings);
            reward = reward.sub(reward.fee(reward.penalty));

            self.calculatedReward.food = reward.food;
            self.calculatedReward.wood = reward.wood;
            self.calculatedReward.rock = reward.rock;
            self.calculatedReward.iron = reward.iron;
            self.calculatedReward.amount = amount;

        }
      
        Structure storage structure = s.getStructure(self.provinceId, self.assetTypeId);
        structure.available = structure.available - amount;
        structure.total = structure.total - amount;

        Province storage province = s.getProvince(self.provinceId);
        province.addReward(self.calculatedReward, true); // Taxed because the user did produce some commodity.
    }


    function burn(StructureEvent storage self, AppStorage storage s) internal returns(uint256 amount) {
        amount = self.calculatedReward.amount;

        if(!self.hasTimeExpired()) {
            amount = self.reducedOnTimePassed(amount);

            // Increase the number with penalty.
            amount = (amount * (self.calculatedReward.penalty + 1e18)) / 1e18;
            amount = amount > self.calculatedReward.amount ? self.calculatedReward.amount : amount;
            self.calculatedReward.amount = amount;
        }
      
        Structure storage structure = s.getStructure(self.provinceId, self.assetTypeId);
        structure.available = structure.available - amount;
        structure.total = structure.total - amount;
    }
    

    function updatePopulation(StructureEvent storage self, Province storage _province) internal {
        assert(self.calculatedCost.attrition <= 1e18); // Cannot be more than 100%

        // _cost.manPowerAttrition is the calculated cost in manPower attrition
        uint256 attritionAmount = self.reducedOnTimePassed(self.calculatedCost.manPowerAttrition); // Attrition increases over time.
        
        _province.populationAvailable = _province.populationAvailable + self.calculatedCost.manPower - attritionAmount; // Add manPower back to the province and reduce by attrition
        _province.populationTotal = _province.populationTotal - attritionAmount; // Total population decreases over time because of attrition.
    }

    // Remove the event from the active list and update the index of the other events.
    function moveActiveStructureEvent(StructureEvent storage self, AppStorage storage s) internal  {
        uint256 lastEventIndex = s.provinceActiveStructureEventList[self.provinceId].length - 1;
        uint256 lastEventId = s.provinceActiveStructureEventList[self.provinceId][lastEventIndex];
        
        s.structureEvents[lastEventId].provinceActiveEventIndex = self.provinceActiveEventIndex; // Update the index of the last event.

        s.provinceActiveStructureEventList[self.provinceId][self.provinceActiveEventIndex] = 
            s.provinceActiveStructureEventList[self.provinceId][lastEventIndex];
        
        s.provinceActiveStructureEventList[self.provinceId].pop();

        // Add the event to the completed list
        s.provinceStructureEventList[self.provinceId].push(self.id);
    }

    
    function decreaseAvailableStructure(StructureEvent storage self, AppStorage storage s) internal {
        Structure storage structure = s.getStructure(self.provinceId, self.assetTypeId);
        require(structure.available >= self.multiplier, "Not enough structures available");
        structure.available = structure.available - self.multiplier;
    }

    function increaseAvailableStructure(StructureEvent storage self, AppStorage storage s) internal {
        Structure storage structure = s.getStructure(self.provinceId, self.assetTypeId);
        require(structure.total >= structure.available + self.multiplier, "Cannot increase available structures more than total structures");
        structure.available = structure.available + self.multiplier;
    }

    

}