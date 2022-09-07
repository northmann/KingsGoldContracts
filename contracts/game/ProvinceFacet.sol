// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/LibAppStorageExtensions.sol";
import "../libraries/LibMeta.sol";
import "../general/ReentrancyGuard.sol";
import {LibRoles} from "../libraries/LibRoles.sol";
import "./GameAccess.sol";

contract ProvinceFacet is Game, ReentrancyGuard, GameAccess {
    using LibAppStorageExtensions for AppStorage;

    constructor() ReentrancyGuard() {}

    struct Args {
        EventAction eventActionId;
        AssetType assetTypeId;
        uint256 provinceId;
        uint256 multiplier;
        uint256 rounds;
        uint256 hero;
    }

    function pack(uint256 high, uint256 low) public pure returns (uint256 packed) {
        return (uint256(high) << 128) | uint256(low);
    }

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

    function createEvent(address userAddress, Args calldata args) internal {
        // check that the hero exist and is controlled by user.
        console.log("createStructureEvent start");

        Province storage province = s.provinces[args.provinceId]; // Struct from mapping

        console.log("createStructureEvent create Event");

        uint256 eventId = pack(args.provinceId, s.provinceStructureEventList[args.provinceId].length);

        StructureEvent memory e;

        e.id = eventId;
        e.eventActionId = args.eventActionId;
        e.assetTypeId = args.assetTypeId;
        e.provinceId = args.provinceId;
        e.multiplier = args.multiplier;
        e.rounds = args.rounds;
        e.hero = args.hero;
        e.userAddress = userAddress;
        e.creationTime = block.timestamp;
        e.state = EventState.Active;

        AssetAction memory assetAction = s.getAssetAction(args.assetTypeId, args.eventActionId);

        console.log("createStructure calculate cost");

        e.calculatedCost = s.calculateCost(args.multiplier, args.rounds, assetAction.cost);
        e.calculatedReward = s.calculateCost(args.multiplier, args.rounds, assetAction.reward);

        console.log("createStructure check manpower");
        require(e.calculatedCost.manPower <= province.populationAvailable, "not enough population");

        province.populationAvailable = province.populationAvailable - e.calculatedCost.manPower;

        console.log("createStructure spend commodities Event");
        // Spend the resouces on the behalf of the user
        s.spendCommodities(e.calculatedCost);

        console.log("createStructure add event");

        User storage user = s.users[userAddress];
        uint256 index = user.structureEventCount + 1; // Get the index of the event. Zero index is empty!
        user.structureEventCount = index; // Increase the count of events.

        s.structureEvents[eventId] = e; // Add the event to the user's event mapping.

        s.provinceActiveStructureEventList[args.provinceId].push(eventId);
        s.provinceCheckpoint[args.provinceId].activeStructureEvents = block.timestamp;

        s.provinceStructureEventList[args.provinceId].push(eventId);
        s.provinceCheckpoint[args.provinceId].structureEvents = block.timestamp;

        s.userActiveStructureEventList[msg.sender].push(eventId);
        s.userCheckpoint[msg.sender].activeStructureEvents = block.timestamp;

        s.userStructureEventList[msg.sender].push(eventId);
        s.userCheckpoint[msg.sender].structureEvents = block.timestamp;
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

    function getProvinceActiveStructureEvents(uint256 _provinceId) public view returns (StructureEvent[] memory) {
        Province memory province = s.provinces[_provinceId];
        require(province.id == _provinceId, "Province id mismatch");

        uint256 length = s.provinceActiveStructureEventList[_provinceId].length;

        StructureEvent[] memory structureEvents = new StructureEvent[](length);

        for (uint256 i = 0; i < length; i++) {
            structureEvents[i] = s.structureEvents[s.provinceActiveStructureEventList[_provinceId][i]];
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

    function createStructureEvent(Args calldata args) external nonReentrant {
        createEvent(msg.sender, args);
    }

    // --------------------------------------------------------------
    // Internal Functions
    // --------------------------------------------------------------
}
