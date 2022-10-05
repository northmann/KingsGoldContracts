// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/AppStorageExtensions.sol";
import "../libraries/LibMeta.sol";
import "../general/ReentrancyGuard.sol";
import "../general/Game.sol";
import {LibRoles} from "../libraries/LibRoles.sol";
import "./GameAccess.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


contract ProvinceFacet is Game, ReentrancyGuard, GameAccess {
    using AppStorageExtensions for AppStorage;
    using EnumerableSet for EnumerableSet.UintSet;


    constructor() ReentrancyGuard() {}


    // --------------------------------------------------------------
    // Modifier Functions
    // --------------------------------------------------------------

    // --------------------------------------------------------------
    // Internal Functions
    // --------------------------------------------------------------

    function mintProvince(string memory _name, address _target) internal returns (uint256) {
        // TODO: Check name, no illegal chars
        User storage user = s.users[_target];

        require(user.provinces.length <= s.baseSettings.provinceLimit, "Cannot exeed the limit of provinces");

        console.log("Gold Balance: ", s.baseSettings.gold.balanceOf(msg.sender));

        // Check if the user has enough money to pay for the province
        uint256 price = s.baseSettings.provinceCost + s.baseSettings.provinceDeposit;
        require(price <= s.baseSettings.gold.balanceOf(_target), "Not enough tokens in reserve");

        // Transfer gold from user to the treasury (Game)
        if (!s.baseSettings.gold.transferFrom(_target, address(this), price)) revert("KingsGold transfer failed from sender to treasury.");

        // Create the province
        uint256 tokenId = s.baseSettings.provinceNFT.mint(_target);

        console.log("TokenId: ", tokenId);

        // Add the province to the user account
        s.createProvince(tokenId, _name, _target);
        Province storage province = s.createProvince(tokenId, _name, _target);
        province.deposit = s.baseSettings.provinceDeposit; // Set the deposit here as the payment has been made.

        // Mint resources to the user as a reward for creating a province.
        s.baseSettings.food.mint(_target, s.baseSettings.provinceFoodInit);
        s.baseSettings.wood.mint(_target, s.baseSettings.provinceWoodInit);
        s.baseSettings.rock.mint(_target, s.baseSettings.provinceRockInit);
        s.baseSettings.iron.mint(_target, s.baseSettings.provinceIronInit);

        console.log("Adding default one Farm to province");
        Structure storage structure = s.addStructureSafe(tokenId, AssetType.Farm);
        structure.available = structure.available + 1;
        structure.total = structure.total + 1;

        return tokenId;
    }



    // --------------------------------------------------------------
    // Event Hooks
    // --------------------------------------------------------------

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function getProvinceNFT() public view returns (IProvinceNFT provinceNFT) {
        provinceNFT = s.baseSettings.provinceNFT;
    }

    // function getUserProvinceCount() public view returns (uint256 count) {
    //     count = s.getUser().provinces.length;
    // }

    // function getUserProvinceId(uint256 _index) public view returns (uint256 id) {
    //     User storage user = s.getUser();
    //     require(user.provinces.length > 0, "User has no provinces");
    //     require(_index < user.provinces.length, "Province index out of bounds");

    //     id = user.provinces[_index];
    // }

    // function getUserProvince(uint256 _index) public view returns (Province memory province) {
    //     uint256 id = getUserProvinceId(_index);

    //     province = s.provinces[id];
    // }

    function getProvince(uint256 _id) public view returns (Province memory province) {
        province = s.getProvince(_id);
        require(province.id == _id, "Province not found");
    }

    function getProvinceStructures(uint256 _provinceId) public view returns (Structure[] memory) {
        Province memory province = s.provinces[_provinceId];
        require(province.id == _provinceId, "Province id mismatch");

        Structure[] memory structures = new Structure[](province.structureList.length);

        for (uint256 i = 0; i < province.structureList.length; i++) {
            structures[i] = s.structures[_provinceId][province.structureList[i]];
        }

        return structures;
    }

    function getProvinceActiveStructureTasks(uint256 _provinceId) public view returns (StructureEvent[] memory) {
        Province memory province = s.provinces[_provinceId];
        require(province.id == _provinceId, "Province id mismatch");

        uint256[] memory list = s.provinceActiveStructureTaskList[_provinceId].values();

        StructureEvent[] memory structureEvents = new StructureEvent[](list.length);

        for (uint256 i = 0; i < list.length; i++) {
            structureEvents[i] = s.structureEvents[list[i]];
        }

        return structureEvents;
    }

    function getProvinceCheckpoint(uint256 _provinceId) public view returns (ProvinceCheckpoint memory checkpoint) {
        checkpoint = s.provinceCheckpoint[_provinceId];
    }

    // --------------------------------------------------------------
    // External Functions
    // --------------------------------------------------------------

    // Everyone should be able to mint new Provinces from a payment in KingsGold
    function createProvince(string memory _name) external nonReentrant returns (uint256 tokenId) {
        tokenId = mintProvince(_name, LibMeta.msgSender());
    }

    function createProvinceAtTarget(string memory _name, address _target)
        external
        nonReentrant
        requiredRole(LibRoles.CONFIG_ROLE)
        returns (uint256 tokenId)
    {
        tokenId = mintProvince(_name, _target);
    }



    // --------------------------------------------------------------
    // Internal Functions
    // --------------------------------------------------------------
}
