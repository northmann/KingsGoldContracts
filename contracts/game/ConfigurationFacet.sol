// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../libraries/LibAppStorage.sol";
//import "../libraries/LibAppStorageExtensions.sol";
//import "../libraries/LibEventExtensions.sol";
//import "../libraries/LibMeta.sol";
import "./Roles.sol";
import "./GameAccess.sol";
import "./AccessControlFacet.sol";



contract ConfigurationFacet is Game, GameAccess {

    bytes32 internal constant CONFIG_ROLE = keccak256("CONFIG_ROLE");


    function setAppStoreAssetAction(AssetType _assetTypeId, EventAction _eventActionId, AssetAction memory _assetAction) public requiredRole(CONFIG_ROLE) {
        bytes32 assetActionID = keccak256(abi.encodePacked(_assetTypeId, _eventActionId));
        s.assetActions[assetActionID] = _assetAction;
    }

    function setAppStoreAsset(Asset memory asset) public requiredRole(CONFIG_ROLE) {
        s.assets[asset.typeId] = asset;
    }

}

