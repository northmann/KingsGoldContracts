// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/LibAppStorageExtensions.sol";
import "../libraries/LibMeta.sol";
import "../general/ReentrancyGuard.sol";

contract ProvinceFacet is Game, ReentrancyGuard {
    using LibAppStorageExtensions for AppStorage;

    constructor() ReentrancyGuard() {}

    // --------------------------------------------------------------
    // Modifier Functions
    // --------------------------------------------------------------

    // --------------------------------------------------------------
    // Internal Functions
    // --------------------------------------------------------------

    // --------------------------------------------------------------
    // Event Hooks
    // --------------------------------------------------------------

    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function getProvinceNFT() public view returns (IProvinceNFT provinceNFT) {
        provinceNFT = s.provinceNFT;
    }

    function getUserProvinceCount() public view returns (uint256 count) {
        count = s.getUser().provinces.length;
    }

    function getUserProvinceId(uint256 _index) public view returns (uint256 id) {
        User storage user = s.getUser();
        require(user.provinces.length > 0, "User has no provinces");
        require(_index < user.provinces.length, "Province index out of bounds");

        id = user.provinces[_index];
    }

    function getUserProvince(uint256 _index) public view returns (Province memory province) {
        uint256 id = getUserProvinceId(_index);

        province = s.provinces[id];
    }

    function getProvinceStructures(uint256 _provinceId) public view returns (Structure[] memory) {

        Province memory province = s.provinces[_provinceId];
        require(province.id == _provinceId, "Province id mismatch");

        Structure[] memory structures = new Structure[](province.structureList.length);

        for(uint256 i = 0; i < province.structureList.length; i++) {
            structures[i] = s.structures[_provinceId][province.structureList[i]];
        }

        return structures;
    }

    // function getProvince(uint256 _provinceId) public view returns (
    //     uint256 id,
    //     string memory name,
    //     address owner,
    //     address vassal,
    //     uint32 positionX,
    //     uint32 positionY,
    //     uint32 plains,   // Food
    //     uint32 forest,   // Wood
    //     uint32 mountain, // Stone
    //     uint32 hills,    // Gold and iron ore
    //     uint256 populationTotal,
    //     uint256 populationAvailable,
    //     address armyContract
    // ) {
    //     Province memory province = s.provinces[_provinceId];
    //     require(province.id == 0, "Province do not exist");
    //     require(province.id == _provinceId, "Province id mismatch");

    //     return (
    //         province.id,
    //         province.name,
    //         province.owner,
    //         province.vassal,
    //         province.positionX,
    //         province.positionY,
    //         province.plains,
    //         province.forest,
    //         province.mountain,
    //         province.hills,
    //         province.populationTotal,
    //         province.populationAvailable,
    //         province.armyContract
    //     );
    // }

    // --------------------------------------------------------------
    // External Functions
    // --------------------------------------------------------------

    // Everyone should be able to mint new Provinces from a payment in KingsGold
    function createProvince(string memory _name) external nonReentrant returns (uint256) {
        // TODO: Check name, no illegal chars

        console.log("Creating province: ", _name);
        // Make sure that the user account exist and if not then created it automatically.
        User storage user = s.getUser();

        console.log("User.kingdom: ", user.kingdom);
        console.log("user.provinces.length: ", user.provinces.length);

        require(user.provinces.length <= s.provinceLimit, "Cannot exeed the limit of provinces");

        console.log("Gold Balance: ", s.gold.balanceOf(msg.sender));

        // Check if the user has enough money to pay for the province
        require(s.baseProvinceCost <= s.gold.balanceOf(msg.sender), "Not enough tokens in reserve");

        // Transfer gold from user to the treasury (Game)
        if (!s.gold.transferFrom(msg.sender, address(this), s.baseProvinceCost)) revert("KingsGold transfer failed from sender to treasury.");

        // Create the province
        uint256 tokenId = s.provinceNFT.mint(msg.sender);

        console.log("TokenId: ", tokenId);

        // Add the province to the user account
        s.createProvince(tokenId, _name);

        console.log("User Province length: ", s.users[msg.sender].provinces.length);

        console.log("Minting");
        // Mint resources to the user as a reward for creating a province.
        s.food.mint(msg.sender, s.baseCommodityReward);
        s.wood.mint(msg.sender, s.baseCommodityReward);
        s.rock.mint(msg.sender, s.baseCommodityReward);
        s.iron.mint(msg.sender, s.baseCommodityReward);

        console.log("Minting done");

        console.log("Adding default one Farm to province");
        Structure storage structure = s.addStructureSafe(tokenId, AssetType.Farm);
        structure.available = structure.available + 1;
        structure.total = structure.total + 1;

        return tokenId;
    }


    struct Args {
        EventAction action;
        AssetType assetTypeId;
        uint256 provinceId;
        uint256 multiplier;
        uint256 rounds;
        uint256 hero;
    }

    function createStructureEvent(Args calldata args
    ) external {
        // check that the hero exist and is controlled by user.
        console.log("createStructureEvent start");

        Province storage province = s.provinces[args.provinceId]; // Struct from mapping
        require(province.owner == msg.sender || province.vassal == msg.sender, "Province does not belong to you");
        //Asset storage asset = s.assets[args.assetTypeId]; // Struct from mapping
        //require(asset.typeId == args.assetTypeId, "Asset typeId does not match");

        console.log("createStructureEvent create Event");

        StructureEvent memory e;

        e.action = args.action;
        e.assetTypeId = args.assetTypeId;
        e.provinceId = args.provinceId;
        e.multiplier = args.multiplier;
        e.rounds = args.rounds;
        e.hero = args.hero;        
        e.userAddress = msg.sender;
        e.creationTime = block.timestamp;
        e.state = EventState.Active;

        AssetAction memory assetAction = s.getAssetAction(args.assetTypeId, args.action);

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
        
        User storage user = s.users[msg.sender];
        uint256 index = user.structureEventCount+1; // Get the index of the event. Zero index is empty!
        user.structureEventCount = index; // Increase the count of events.

        s.structureEvents[msg.sender][index] = e; // Add the event to the user's event mapping.
        s.activeStructureEventList[msg.sender].push(index);
    }

    // --------------------------------------------------------------
    // Internal Functions
    // --------------------------------------------------------------


}
