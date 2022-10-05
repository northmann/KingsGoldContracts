// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "hardhat/console.sol";

//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../libraries/AppStorage.sol";
import "../libraries/AppStorageExtensions.sol";
import { LibRoles } from "../libraries/LibRoles.sol";
import "./GameAccess.sol";
import "./AccessControlFacet.sol";
import "../general/Game.sol";



contract ConfigurationFacet is Game, GameAccess {

    using AppStorageExtensions for AppStorage;

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function getBaseSettings() public view returns (BaseSettings memory settings) {

        settings = s.baseSettings;
    }


    function getAsset(AssetType _assetTypeId) public view returns (Asset memory asset) {
        asset = s.assets[_assetTypeId];
    }

    function getAssets() public view returns (Asset[] memory) {

        uint256 size = uint256(AssetType.Last);
        Asset[] memory _n = new Asset[](size);
        for(uint256 i = 0; i < size; i++ ) 
        {
            _n[i] = s.assets[AssetType(i)];
        }
        return _n;
    }

    function getAssetAction(AssetType _assetTypeId, EventAction _eventActionId) public view returns(AssetAction memory assetAction) 
    {
        bytes32 assetActionID = keccak256(abi.encodePacked(_assetTypeId, _eventActionId));
        assetAction = s.assetActions[assetActionID];
    }

    // --------------------------------------------------------------
    // External Functions
    // --------------------------------------------------------------


    function setBaseSettings(BaseSettings memory _args) public requiredRole(LibRoles.CONFIG_ROLE) {
        s.baseSettings = _args;
    }

    function addStructure(uint256 _provinceID, AssetType _assetTypeId, uint256 _count) public requiredRole(LibRoles.CONFIG_ROLE) {
        Structure storage structure = s.addStructureSafe(_provinceID, _assetTypeId);
        structure.available = structure.available + _count;
        structure.total = structure.total + _count;
    }


    function setAppStoreAssetActions(AssetAction[] calldata _assetActions) public requiredRole(LibRoles.CONFIG_ROLE) {
        for(uint i = 0; i < _assetActions.length; i++) {
            AssetAction memory item = _assetActions[i];
            setAppStoreAssetAction(item);
        }
    }

    function setAppStoreAssetAction(AssetAction memory _assetAction) public requiredRole(LibRoles.CONFIG_ROLE) {
        bytes32 assetActionID = keccak256(abi.encodePacked(_assetAction.assetTypeId, _assetAction.eventActionId));
        s.assetActions[assetActionID] = _assetAction;
    }

    function setAppStoreAssets(Asset[] calldata assets) public requiredRole(LibRoles.CONFIG_ROLE) {

        for(uint i = 0; i < assets.length; i++) {
            Asset memory asset = assets[i];
            setAppStoreAsset(asset);
        }
    }

    function setAppStoreAsset(Asset memory asset) public requiredRole(LibRoles.CONFIG_ROLE) {
        //console.log("setAppStoreAssets:", asset);
        //console.log("setAppStoreAssets Type: ", asset.typeId, " - GroupID:", asset.groupId);

        s.assets[asset.typeId] = asset;
    }

    function setAppStoreArmyUnitType(ArmyUnitProperties memory armyUnitType) public requiredRole(LibRoles.CONFIG_ROLE) {
        s.armyUnitTypes[armyUnitType.armyUnitTypeId] = armyUnitType;
    }

    function setAppStoreArmyUnitTypes(ArmyUnitProperties[] calldata armyUnitTypes) public requiredRole(LibRoles.CONFIG_ROLE) {
        for(uint i = 0; i < armyUnitTypes.length; i++) {
            ArmyUnitProperties memory armyUnitType = armyUnitTypes[i];

            s.armyUnitTypes[armyUnitType.armyUnitTypeId] = armyUnitType;
        }
    }


    function mintGold(address to, uint256 amount) public requiredRole(LibRoles.MINTER_ROLE) {
        s.baseSettings.gold.mint(to, amount);
    }

    function approveGold(address _from, uint256 _amount) public requiredRole(LibRoles.MINTER_ROLE) {
        s.baseSettings.gold.approveFrom(_from, _amount);
    }

    function mintCommodities(address _to, uint256 _food, uint256 _wood, uint256 _rock, uint256 _iron) public requiredRole(LibRoles.MINTER_ROLE) {
        s.baseSettings.food.mint(_to, _food);
        s.baseSettings.wood.mint(_to, _wood);
        s.baseSettings.rock.mint(_to, _rock);
        s.baseSettings.iron.mint(_to, _iron);
    }

    function approveCommodities(address _from, uint256 _food, uint256 _wood, uint256 _rock, uint256 _iron) public requiredRole(LibRoles.MINTER_ROLE) {
        s.baseSettings.food.approveFrom(_from, _food);
        s.baseSettings.wood.approveFrom(_from, _wood);
        s.baseSettings.rock.approveFrom(_from, _rock);
        s.baseSettings.iron.approveFrom(_from, _iron);
    }
    
}

