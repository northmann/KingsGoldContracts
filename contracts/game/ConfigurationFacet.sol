// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/LibAppStorageExtensions.sol";
//import "../libraries/LibEventExtensions.sol";
//import "../libraries/LibMeta.sol";
import { LibRoles } from "../libraries/LibRoles.sol";
import "./GameAccess.sol";
import "./AccessControlFacet.sol";



contract ConfigurationFacet is Game, GameAccess {

    using LibAppStorageExtensions for AppStorage;

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
        bytes32 assetActionID = keccak256(abi.encodePacked(_assetAction.assetTypeId, _assetAction.actionId));
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

}

