// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";


import "../interfaces/IKingsGold.sol";
import "../interfaces/IProvinceNFT.sol";
import "../interfaces/ICommodity.sol";


//import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";

enum EventState {
    Active,
    PaidFor,
    Completed,
    Cancelled
}

enum EventAction {
    Build,
    Demolish,
    Yield
}

enum StructureType {
    None,
    Farm,
    Sawmill,
    Blacksmith,
    Quarry,
    Barrack,
    Stable,
    Market,
    Temple,
    University,
    Wall,
    Watchtower,
    Castle,
    Fortress
}

enum AssetType {
    None,
    Farm,
    Sawmill,
    Blacksmith,
    Quarry,
    Barrack,
    Stable,
    Market,
    Temple,
    University,
    Wall,
    Watchtower,
    Castle,
    Fortress,
    Population

}

struct Hero {
    uint256 tokenId;
    string name;
    uint256 level;
    uint256 experience;
    // Attributes    
}

struct ResourceFactor {
    uint256 manPower;
    uint256 manPowerAttrition;
    uint256 attrition;
    uint256 penalty;
    uint256 time;
    uint256 goldForTime;
    uint256 food;
    uint256 wood;
    uint256 rock;
    uint256 iron;
}


// An asset can be a structure, population, items, troops, armies, etc.
struct AssetAction {
    ResourceFactor cost;    // The cost of resources for this asset
    ResourceFactor reward;  // The reward of resources for this asset
    uint256 timeRequired;
    uint256 goldForTime;
    uint256 attrition;
}

struct Asset {
    AssetType typeId;
    string name;
    string description;

    // AssetData build;
    // AssetData demolish;
    // AssetData yield;

    uint256 requiredUserLevel;
    uint256[] requiredAssets; // Assets required to build this asset
}

struct Structure {
    AssetType assetTypeId;
    string name;
    string description;

    uint256 available;
    uint256 total;
}

struct StructureEvent{

    // Function parameter fields
    EventAction action;
    EventState state; // The state of the event.
    AssetType assetTypeId;    // A mapping id to an asset
    uint256 provinceId; // The province this event is in.
    uint256 multiplier; // Multiply the effect of the event. More Farms create more yield etc.
    uint256 rounds; // Repeat the event a number of rounds.
    uint256 hero; // TokenId of the hero NFT.

    // Auto initialized fields
    // The user who created the event. (msg.Sender). 
    // If the user is a vassal of the province, 
    // then yield events are split between the vassal and owner of the province.
    address userAddress; 

    uint256 creationTime; // The time the event was created.
    uint256 endTime; // The time the event ended, completed or cancelled.



    ResourceFactor calculatedCost;
    ResourceFactor calculatedReward;

    // address receiver;
}


struct Province {


    uint256 id;
    //IContinent public override continent;
    //IWorld public override world;

    string name;

    address owner;
    address vassal;

    uint32 positionX;
    uint32 positionY;

    uint32 plains;   // Food
    uint32 forest;   // Wood
    uint32 mountain; // Stone
    uint32 hills;    // Gold and iron ore

    uint256 populationTotal;
    uint256 populationAvailable;
    address armyContract;
    
    uint256[] activeStructureEvents;

    uint256[] structureList;
}

struct User {

    uint256 level; // The level of the user, opens up for more posibilities.
    //EnumerableSet.AddressSet provinces;
    uint256[] provinces;

    address kingdom;
    address alliance;
    uint256 allianceIndex;

    bool isVassal;

    //address[] allies;
    uint256 structureEventCount;
}

struct Ally {
    address user;
    uint256 status;
}

struct AppStorage {
    mapping(address => User) users;
    address[] userList; // All users in the system.

    mapping(uint256 => Province) provinces;    // Provinces are indexed by the ID from the ProvinceNFT contract
    uint256[] provinceList; // All provinces in the system.

    mapping(AssetType => Asset) assets; // Assets are indexed by the AssetType enum.

    mapping(uint256 => mapping(AssetType => Structure)) structures; // ProvinceID => StructureID (AssetTypeId) => Structure

    //mapping(address => uint256[]) structureEventList; // All finished structure events for a user. Also used for generating ID's for new events.
    mapping(address => uint256[]) activeStructureEventList; // All active structure events for a user.

    mapping(address => mapping(uint256 => StructureEvent)) structureEvents; // Structure events are indexed by the user who created the event. 

    mapping(address => uint256[]) eventHistory; // All events that a user have ever done. Not on the User struct as the list can become very large.

    mapping(address => mapping (address => bool)) allianceApprovals; // Alliances can approve other users to join their alliance.
    mapping(address => Ally[]) alliances; 

    mapping(bytes32 => AssetAction) assetActions; 


    uint256 baseGoldCost; // The base cost of gold, this is ajustable.
    uint256 provinceLimit;
    uint256 baseProvinceCost;
    uint256 baseCommodityReward;
    uint256 baseUnit;
    uint256 timeBaseCost;
    uint256 goldForTimeBaseCost;
    uint256 foodBaseCost;
    uint256 woodBaseCost;
    uint256 rockBaseCost;
    uint256 ironBaseCost;

    uint256 vassalTribute; // The percentage of asset income vassal pays to the owner of the province.

    Province defaultProvince;

    IProvinceNFT provinceNFT;
    IKingsGold gold;
    ICommodity food;
    ICommodity wood;
    ICommodity rock;
    ICommodity iron;
    
}

library LibAppStorage {
    function appStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }
}


contract Game {
    AppStorage internal s;
}

// abstract contract AppStorage {

//     bytes32 constant USERS_STORAGE_POSITION = keccak256("UserAccount.userStorage");

//     struct UsersStorage {
//         mapping(address => User) users;
//     }


//     function usersStorage() internal pure returns (UsersStorage storage ds) {
//         bytes32 position = USERS_STORAGE_POSITION;
//         assembly {
//             ds.slot := position
//         }
//     }

//     function getUser() internal view returns (User user) {
//         usersStorage().users[msg.sender];
//     }
// }