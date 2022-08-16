// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/LibAppStorageExtensions.sol";
import "../libraries/LibMeta.sol";
import "../general/ReentrancyGuard.sol";


contract ProvinceFacet is Game, ReentrancyGuard
{
    using LibAppStorageExtensions for AppStorage;

    constructor() ReentrancyGuard() {
    }

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

    function getUserProvinceCount() public view returns (uint count) {
        count = s.getUser().provinces.length;
    }

    function getUserProvinceId(uint256 _index) public view returns (uint id) {
        User storage user = s.getUser();
        require(user.provinces.length > 0, "User has no provinces");
        require(_index < user.provinces.length, "Province index out of bounds");

        id = user.provinces[_index];
    }

    function getUserProvince(uint256 _index) public view returns (Province memory province) {
        uint256 id = getUserProvinceId(_index); 
        
        province = s.provinces[id];
    }


    // --------------------------------------------------------------
    // External Functions
    // --------------------------------------------------------------

     // Everyone should be able to mint new Provinces from a payment in KingsGold
    function createProvince(string memory _name) external nonReentrant returns(uint256) {  
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
        if(!s.gold.transferFrom(msg.sender, address(this), s.baseProvinceCost))
            revert("KingsGold transfer failed from sender to treasury.");

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

        return tokenId;
    }
    
}