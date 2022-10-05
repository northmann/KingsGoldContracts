// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "./AppStorage.sol";
import "./LibMeta.sol";
import "./StructureEventExtensions.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library AppStorageExtensions {
    using StructureEventExtensions for StructureEvent;
    using AppStorageExtensions for AppStorage;
    using EnumerableSet for EnumerableSet.UintSet;


    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function appStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

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
        //console.log("s.getUser() - msg.sender: %s - number of provinces: %s", LibMeta.msgSender(), user.provinces.length);
    }

    function getUser(AppStorage storage self, address _target) internal view returns (User storage user) {
        user = self.users[_target];
    }


    function getUserCheckpoint(AppStorage storage self, address _user) internal view returns (UserCheckpoint memory checkpoint) {
        checkpoint = self.userCheckpoint[_user];
    }


    function getAssetAction(AppStorage storage self, AssetType _assetTypeId, EventAction _action) internal view returns (AssetAction memory assetAction) {
        bytes32 assetActionID = keccak256(abi.encodePacked(_assetTypeId, _action));
        assetAction = self.assetActions[assetActionID];
    }



    // --------------------------------------------------------------
    // Write Functions
    // --------------------------------------------------------------

    function nextArmyId(AppStorage storage self) internal returns (uint256 armyCount_) {
        armyCount_ = ++self.armyCount;
    }
    

    function addStructureSafe(AppStorage storage self, uint256 _provinceId, AssetType _assetTypeId)
        internal
        returns (Structure storage structure)
    {
        structure = getStructure(self, _provinceId, _assetTypeId);
        if(structure.assetTypeId == AssetType.None) {
            structure.assetTypeId = _assetTypeId;

            self.provinceStructureList[_provinceId].add(uint256(_assetTypeId));
        }
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