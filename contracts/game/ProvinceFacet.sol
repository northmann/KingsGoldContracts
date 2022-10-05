// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/AppStorage.sol";
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
    // Event Hooks
    // --------------------------------------------------------------

    event ProvinceMinted(uint256 indexed id, Position indexed position, string name);


    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function getProvinceNFT() public view returns (IProvinceNFT provinceNFT) {
        provinceNFT = s.baseSettings.provinceNFT;
    }


    function getProvince(uint256 _id) public view returns (Province memory province) {
        province = s.getProvince(_id);
        require(province.id == _id, "Province not found");
    }

    function getProvinces() public view returns (Province[] memory provinces_) {
        provinces_ = _getProvinces(s.provinceList.values());
    }

    function getUserProvinces(address _user) public view returns (Province[] memory provinces_) {
        provinces_ = _getProvinces(s.userProvinces[_user].values());
    }


    function getProvinceStructures(uint256 _provinceId) public view returns (Structure[] memory structures_) {
        structures_ = _getProvinceStructures(_provinceId, s.provinceStructureList[_provinceId].values());
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
        tokenId = _mintProvince(_name, LibMeta.msgSender());
    }

    function createProvinceAtTarget(string memory _name, address _user)
        external
        nonReentrant
        requiredRole(LibRoles.CONFIG_ROLE)
        returns (uint256 tokenId)
    {
        tokenId = _mintProvince(_name, _user);
    }



    // --------------------------------------------------------------
    // Internal Functions
    // --------------------------------------------------------------

    function _getProvinceStructures(uint256 _provinceId, uint256[] memory _list)
        internal
        view
        returns (Structure[] memory structures_)
    {
        structures_ = new Structure[](_list.length);

        for (uint256 i = 0; i < _list.length; i++) {
            structures_[i] = s.structures[_provinceId][AssetType(_list[i])];
        }
    }

    function _getProvinces(uint256[] memory _ids) internal view returns (Province[] memory provinces_) {
        provinces_ = new Province[](_ids.length);
        for(uint256 i = 0; i < _ids.length; i++) {
            provinces_[i] = s.provinces[_ids[i]];
        }
    }


    function _mintProvince(string memory _name, address _user) internal returns (uint256) {
        // TODO: Check name, no illegal chars

        require(s.userProvinces[_user].length() <= s.baseSettings.provinceLimit, "Cannot exeed the limit of provinces");

        console.log("Gold Balance: ", s.baseSettings.gold.balanceOf(msg.sender));

        // Check if the user has enough money to pay for the province
        uint256 price = s.baseSettings.provinceCost + s.baseSettings.provinceDeposit;
        require(price <= s.baseSettings.gold.balanceOf(_user), "Not enough tokens in reserve");

        // Transfer gold from user to the treasury (Game)
        if (!s.baseSettings.gold.transferFrom(_user, address(this), price)) revert("KingsGold transfer failed from sender to treasury.");

        // Create the province
        uint256 tokenId = s.baseSettings.provinceNFT.mint(_user);

        console.log("TokenId: ", tokenId);

        // Add the province to the user account
        Province storage province = _createProvince(tokenId, _name, _user);
        province.deposit = s.baseSettings.provinceDeposit; // Set the deposit here as the payment has been made.

        // Mint resources to the user as a reward for creating a province.
        s.baseSettings.food.mint(_user, s.baseSettings.provinceFoodInit);
        s.baseSettings.wood.mint(_user, s.baseSettings.provinceWoodInit);
        s.baseSettings.rock.mint(_user, s.baseSettings.provinceRockInit);
        s.baseSettings.iron.mint(_user, s.baseSettings.provinceIronInit);

        console.log("Adding default one Farm to province");
        Structure storage structure = s.addStructureSafe(tokenId, AssetType.Farm);
        structure.available = structure.available + 1;
        structure.total = structure.total + 1;

        emit ProvinceMinted(tokenId, province.position, _name);

        return tokenId;
    }

     
    function _createProvince(uint256 _id, string memory _name, address _target) internal  returns(Province storage) {

        Province memory province = s.provinceTemplate;
        province.id = _id;
        province.name = _name;
        province.owner = _target;
        province.populationAvailable = 100;
        province.populationTotal = 100;

        s.provinces[_id] = province;
        s.provinceList.add(_id);
        s.userProvinces[_target].add(_id);

        //self.provinceCheckpoint[_id].province = block.timestamp;

        return s.provinces[_id];
    }


}
