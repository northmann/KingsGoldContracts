// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./LibAppStorage.sol";
import "./LibMeta.sol";
import "./LibEventExtensions.sol";

library LibAppStorageExtensions {
    using LibEventExtensions for StructureEvent;
    using LibAppStorageExtensions for AppStorage;


    function getAsset(AppStorage storage self, AssetType _assetTypeId) internal view returns (Asset storage) {
        return self.assets[_assetTypeId];
    }

    function getProvince(AppStorage storage self, uint256 _id) internal view returns (Province storage province) {
        province = self.provinces[_id];
        require(province.owner == msg.sender || province.vassal == msg.sender, "Caller has no write access to Province");
    }

    function getStructure(AppStorage storage self, uint256 _provinceId, AssetType _assetTypeId) internal view returns (Structure storage structure) {
        structure = self.structures[_provinceId][_assetTypeId];
    }

    function getStructureSafe(AppStorage storage self, uint256 _provinceId, AssetType _assetTypeId)
        internal
        returns (Structure storage structure)
    {
        structure = getStructure(self, _provinceId, _assetTypeId);
        if(structure.assetTypeId == AssetType.None) {
            structure.assetTypeId = _assetTypeId;
            Asset storage asset = getAsset(self, _assetTypeId);
            structure.name = asset.name;
            structure.description = asset.description;
        }
    }


    function getStructureEvent(AppStorage storage self, uint256 _id) internal view returns (StructureEvent storage structureEvent) {
        structureEvent = self.structureEvents[msg.sender][_id];
        require(structureEvent.userAddress == msg.sender, "Illegal user");
    }


    function getUser(AppStorage storage self) internal view returns (User storage user) {
        user = self.users[LibMeta.msgSender()];
    }


    function createProvince(AppStorage storage self, uint _id, string memory _name) internal {
        require(self.provinces[_id].id == 0, "Province already exists");

        Province memory province = self.defaultProvince;
        province.id = _id;
        province.name = _name;
        province.owner = msg.sender;

        self.provinces[_id] = province;
        self.provinceList.push(_id);
        self.users[msg.sender].provinces.push(_id);
    }


    function getAssetAction(AppStorage storage self, AssetType _assetTypeId, EventAction _action) internal view returns (AssetAction memory assetAction) {
        bytes32 assetActionID = keccak256(abi.encodePacked(_assetTypeId, _action));
        assetAction = self.assetActions[assetActionID];
    }


    function calculateCost(AppStorage storage self, uint256 _multiplier, uint256 _rounds, ResourceFactor memory _cost) internal view returns (ResourceFactor memory result) {
        result.manPower = _multiplier * _cost.manPower; // The _cost in manPower
        result.attrition = _cost.attrition; // The _cost in attrition
        result.manPowerAttrition = ((result.manPower * result.attrition) / self.baseUnit); // The _cost in manPowerAttrition
        result.penalty = _cost.penalty; // The _cost in penalty
        result.time = _cost.time * _rounds; // Change in manPower could alter this.
        result.goldForTime = _rounds * _multiplier * _cost.goldForTime * self.baseGoldCost;
        result.food = _rounds * _multiplier * _cost.food;
        result.wood = _rounds * _multiplier * _cost.wood;
        result.rock = _rounds * _multiplier * _cost.rock;
        result.iron = _rounds * _multiplier * _cost.iron;
    }

    // function penalizeAmount(uint256 _amount)
    //     internal
    //     view
    //     virtual
    //     returns (uint256)
    // {
    //     uint256 reducedAmount = reducedAmountOnTimePassed(_amount);
    //     uint256 amountLeft = (_amount - reducedAmount);
    //     amountLeft = ((amountLeft * penalty) / 1e18);

    //     return amountLeft;
    // }



    /// @dev Spend the users commodities as payment.
    function spendCommodities(AppStorage storage self, ResourceFactor memory _cost) internal  {
        if(_cost.food > 0) {
            // spend the resources that the event requires
            self.food.spendToTreasury(msg.sender, _cost.food);
        }
        if(_cost.wood > 0) {
            // spend the resources that the event requires
            self.wood.spendToTreasury(msg.sender, _cost.wood);
        }
        if(_cost.rock > 0) {
            // spend the resources that the event requires
            self.rock.spendToTreasury(msg.sender, _cost.rock);
        }
        if(_cost.iron > 0) {
            // spend the resources that the event requires
            self.iron.spendToTreasury(msg.sender, _cost.iron);
        }
    }


}