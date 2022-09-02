// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/LibAppStorageExtensions.sol";
import { LibRoles } from "../libraries/LibRoles.sol";
import "./GameAccess.sol";
import "./AccessControlFacet.sol";



contract ConfigurationFacet is Game, GameAccess {

    using LibAppStorageExtensions for AppStorage;

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------
    function getAsset(AssetType _assetTypeId) public view returns (Asset memory asset) {
        asset = s.assets[_assetTypeId];
    }

    function getAssets() public view returns (Asset[] memory) {

        uint256 size = uint256(AssetType.Last);
        Asset[] memory assets = new Asset[](size);

        for(uint256 i = 0; i <= size; i++) {
            assets[i] = s.assets[AssetType(i)];
        }
        return assets;
    }

    function getAssetAction(AssetType _assetTypeId, EventAction _eventActionId) public view returns(AssetAction memory assetAction) 
    {
        bytes32 assetActionID = keccak256(abi.encodePacked(_assetTypeId, _eventActionId));
        assetAction = s.assetActions[assetActionID];
    }

    // --------------------------------------------------------------
    // External Functions
    // --------------------------------------------------------------

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
        s.assets[asset.typeId] = asset;
    }

    function mintGold(address to, uint256 amount) public requiredRole(LibRoles.MINTER_ROLE) {
        s.gold.mint(to, amount);
    }

    function approveGold(address _from, uint256 _amount) public requiredRole(LibRoles.MINTER_ROLE) {
        s.gold.approveFrom(_from, _amount);
    }

    function mintCommodities(address _to, uint256 _food, uint256 _wood, uint256 _rock, uint256 _iron) public requiredRole(LibRoles.MINTER_ROLE) {
        s.food.mint(_to, _food);
        s.wood.mint(_to, _wood);
        s.rock.mint(_to, _rock);
        s.iron.mint(_to, _iron);
    }

    function approveCommodities(address _from, uint256 _amount) public requiredRole(LibRoles.MINTER_ROLE) {
        s.food.approveFrom(_from, _amount);
        s.wood.approveFrom(_from, _amount);
        s.rock.approveFrom(_from, _amount);
        s.iron.approveFrom(_from, _amount);
    }
    
}

