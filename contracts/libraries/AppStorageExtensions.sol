// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";
import "./LibMeta.sol";
import "./StructureEventExtensions.sol";

library AppStorageExtensions {
    using StructureEventExtensions for StructureEvent;
    using AppStorageExtensions for AppStorage;


    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------


    function getAsset(AppStorage storage self, AssetType _assetTypeId) internal view returns (Asset storage) {
        return self.assets[_assetTypeId];
    }

    function getProvince(AppStorage storage self, uint256 _id) internal view returns (Province storage province) {
        province = self.provinces[_id];
        //require(province.owner == msg.sender || province.vassal == msg.sender, "Caller has no write access to Province");
    }

    function getStructure(AppStorage storage self, uint256 _provinceId, AssetType _assetTypeId) internal view returns (Structure storage structure) {
        structure = self.structures[_provinceId][_assetTypeId];
    }

    function getStructureEvent(AppStorage storage self, uint256 _id) internal view returns (StructureEvent storage structureEvent) {
        structureEvent = self.structureEvents[_id];
    }


    function getUser(AppStorage storage self) internal view returns (User storage user) {
        user = self.users[LibMeta.msgSender()];
        console.log("s.getUser() - msg.sender: %s - number of provinces: %s", LibMeta.msgSender(), user.provinces.length);
    }

    function getAssetAction(AppStorage storage self, AssetType _assetTypeId, EventAction _action) internal view returns (AssetAction memory assetAction) {
        bytes32 assetActionID = keccak256(abi.encodePacked(_assetTypeId, _action));
        assetAction = self.assetActions[assetActionID];
    }


    function calculateCost(AppStorage storage self, uint256 _multiplier, uint256 _rounds, ResourceFactor memory _cost) internal view returns (ResourceFactor memory result) {
        // Rule: Everything cost manPower, manPower always cost food and time.
        uint256 oneHour = 60 * 60;

        uint256 baseTime = _cost.time > 0 ? _cost.time : oneHour; // 1 hour if no time is set
        result.time = baseTime * _rounds; // Change in manPower could alter this.
        result.manPower = _multiplier * _cost.manPower; // The _cost in manPower

        uint256 baseGoldCostForTime = _cost.goldForTime > 0 ? _cost.goldForTime : (_cost.manPower * baseTime * self.baseSettings.goldForTimeBaseCost) / oneHour;
        result.goldForTime = baseGoldCostForTime * _rounds * _multiplier;

        uint256 baseFoodCost = _cost.food > 0 ? _cost.food : (_cost.manPower * baseTime * self.baseSettings.baseUnit)  / oneHour;
        result.food = baseFoodCost * _rounds * _multiplier;

        result.attrition = _cost.attrition; // The _cost in attrition
        result.manPowerAttrition = ((result.manPower * result.attrition) / self.baseSettings.baseUnit); // The _cost in manPowerAttrition
        result.penalty = _cost.penalty; // The _cost in penalty

        result.wood = _rounds * _multiplier * ((_cost.wood * self.baseSettings.baseUnit) / 1e18);
        result.rock = _rounds * _multiplier * ((_cost.rock * self.baseSettings.baseUnit) / 1e18);
        result.iron = _rounds * _multiplier * ((_cost.iron * self.baseSettings.baseUnit) / 1e18);
    }


    // --------------------------------------------------------------
    // Write Functions
    // --------------------------------------------------------------

    function addStructureSafe(AppStorage storage self, uint256 _provinceId, AssetType _assetTypeId)
        internal
        returns (Structure storage structure)
    {
        structure = getStructure(self, _provinceId, _assetTypeId);
        if(structure.assetTypeId == AssetType.None) {
            structure.assetTypeId = _assetTypeId;

            Province storage province = getProvince(self, _provinceId); 
            province.structureList.push(_assetTypeId);

            self.provinceCheckpoint[_provinceId].structures = block.timestamp;
        }
    }

 
    function createProvince(AppStorage storage self, uint256 _id, string memory _name, address _target) internal  returns(Province storage) {
        require(self.provinces[_id].id == 0, "Province already exists");

        Province memory province = self.defaultProvince;
        province.id = _id;
        province.name = _name;
        province.owner = _target;
        province.populationAvailable = 100;
        province.populationTotal = 100;

        self.provinces[_id] = province;
        self.provinceList.push(_id);
        self.users[_target].provinces.push(_id);

        self.provinceCheckpoint[_id].province = block.timestamp;

        return self.provinces[_id];
    }


    /// @dev Spend the users commodities as payment.
    function spendCommodities(AppStorage storage self, ResourceFactor memory _cost) internal  {
        if(_cost.food > 0) {
            // spend the resources that the event requires
            self.baseSettings.food.spendToTreasury(msg.sender, _cost.food);
        }
        if(_cost.wood > 0) {
            // spend the resources that the event requires
            self.baseSettings.wood.spendToTreasury(msg.sender, _cost.wood);
        }
        if(_cost.rock > 0) {
            // spend the resources that the event requires
            self.baseSettings.rock.spendToTreasury(msg.sender, _cost.rock);
        }
        if(_cost.iron > 0) {
            // spend the resources that the event requires
            self.baseSettings.iron.spendToTreasury(msg.sender, _cost.iron);
        }
    }


}