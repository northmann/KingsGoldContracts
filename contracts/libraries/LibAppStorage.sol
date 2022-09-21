// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../interfaces/IKingsGold.sol";
import "../interfaces/IProvinceNFT.sol";
import "../interfaces/ICommodity.sol";
import "../game/AccessControlFacet.sol";

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
    Dismantle,
    Produce,
    Burn
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
    Province,
    City,
    Capital,
    Stronghold,
    Structure,
    Population,

    Militia,
    Infantry,
    Cavalry,
    Archer,
    Siege,
    Last
}

enum AssetProduct {
    None,
    Structure,
    Population,
    Commodity,
    Artifact,
    Army,
    Last
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
    uint256 gold;
    uint256 amount;
}

// An asset can be a structure, population, items, troops, armies, etc.
struct AssetAction {
    AssetType assetTypeId;
    EventAction eventActionId;
    ResourceFactor cost; // The cost of resources for this asset
    ResourceFactor reward; // The reward of resources for this asset
    string method;
}

struct Asset {
    AssetType typeId;
    AssetProduct productId;

    uint256 requiredUserLevel;
    uint256[] requiredAssets; // Assets required to build this asset

    //AssetAction[] actions;
}

// A structure is an instance of an asset.
struct Structure {
    AssetType assetTypeId;
    // string name;
    // string description;
    uint256 available;
    uint256 total;
}

struct StructureEvent {
    uint256 id;
    // Function parameter fields
    EventAction eventActionId;
    EventState state; // The state of the event.
    AssetType assetTypeId; // A mapping id to an asset
    uint256 provinceId; // The province this event is in.
    uint256 provinceActiveEventIndex; // The index of the event in the province's active event list.
    uint256 multiplier; // Multiply the effect of the event. More Farms create more produce etc.
    uint256 rounds; // Repeat the event a number of rounds.
    uint256 hero; // TokenId of the hero NFT.

    uint256 creationTime; // The time the event was created.
    uint256 endTime; // The time the event ended, completed or cancelled.
    ResourceFactor calculatedCost;
    ResourceFactor calculatedReward;
   
}

struct ProvinceCheckpoint {
    uint256 province;
    uint256 structures;
    uint256 structureEvents;
    uint256 activeStructureEvents;
}

struct UserCheckpoint {
    uint256 user;
    uint256 provinces;
    uint256 structures;
    uint256 structureEvents;
    uint256 activeStructureEvents;
}

struct User {
    uint256 level; // The level of the user, opens up for more posibilities as the level increases.

    address kingdom;
    address alliance;
    uint256 allianceIndex;
    uint256 allianceFee; // Should never exceed 100%. The fee the user pays to the alliance.
    uint256 vassalFee; // Should never exceed 100%. The fee that a vassal pays to the owner.
    
    uint256[] provinces;
    uint256[] armies;

    //address[] allies;

}

struct Ally {
    address user;
    uint256 status;
}

enum ArmyUnitType {
    None,
    Militia,
    Soldier,
    Knight,
    Archer,
    Catapult,
    Last
}

enum ArmyState {
    Idle,
    Moving,
    Attacking,
    Defending,
    Retreating,
    Last
}


struct ArmyUnitProperties {
    ArmyUnitType armyUnitTypeId;

    uint128 openAttack;
    uint128 openDefense;
    uint128 seigeAttack;
    uint128 seigeDefense;
    uint128 speed;
    uint128 priority;
    
}

struct ArmyUnit {
    ArmyUnitType armyUnitTypeId;
    uint256 amount;
}

struct Army {
    uint256 id;
    ArmyState state;


    ArmyUnit[] units; // The index is the ArmyUnitType id.
    
    uint256 hero; // TokenId of the hero NFT.

    address owner; // The owner of the army.
    uint256 ownerArmyIndex; // The index of the army in the owner's army list.
    
    uint256 currentProvinceId; // The province the army is currently in or moving from.
    uint256 targetProvinceId; // The province the army is moving to. 

    uint256 startTime;
    uint256 endTime;

}


struct Province {
    uint256 id;
    string name;
    address owner;
    address vassal;
    uint32 positionX;
    uint32 positionY;
    uint32 plains; // Food
    uint32 forest; // Wood
    uint32 mountain; // Stone
    uint32 hills; // Gold and iron ore
    uint256 populationTotal;
    uint256 populationAvailable;
    uint256 garrisonId;
    //uint256[] activeStructureEventList;
    uint256 deposit; // The amount of gold deposited in the province. This gold is claimable by the owner when the province is destroyed.
    uint256 vassalFee;
    uint256 level; // The level of the province. This is the level of the highest structure in the province.

    AssetType[] structureList;
}






struct BaseSettings {

        uint256 baseGoldCost;
        uint256 baseUnit;
        
        uint256 provinceLimit;
        uint256 provinceCost;
        uint256 provinceDeposit;
        uint256 provinceSpend;

        uint256 baseCommodityReward;
        uint256 timeBaseCost;
        uint256 goldForTimeBaseCost;
        
        uint256 provinceFoodInit;
        uint256 provinceWoodInit;
        uint256 provinceRockInit;
        uint256 provinceIronInit;

        uint256 vassalTribute; // The percentage of asset income vassal pays to the owner of the province.

        IProvinceNFT provinceNFT;
        IKingsGold gold;
        ICommodity food;
        ICommodity wood;
        ICommodity rock;
        ICommodity iron;
    }



struct AppStorage {
    mapping(address => User) users;
    mapping(address => UserCheckpoint) userCheckpoint;
    address[] userList; // All users in the system.
    mapping(uint256 => Province) provinces; // Provinces are indexed by the ID from the ProvinceNFT contract
    mapping(uint256 => ProvinceCheckpoint) provinceCheckpoint; // Provinces are indexed by the ID from the ProvinceNFT contract
    uint256[] provinceList; // All provinces in the system.
    mapping(AssetType => Asset) assets; // Assets are indexed by the AssetType enum.
    mapping(uint256 => mapping(AssetType => Structure)) structures; // ProvinceID => StructureID (AssetTypeId) => Structure
    
    mapping(uint256 => StructureEvent) structureEvents; // Structure events are indexed by the user who created the event.
    mapping(uint256 => uint256[]) provinceActiveStructureEventList; // All active structure events for a user.
    mapping(uint256 => uint256[]) provinceStructureEventList; // All structure events for a user.
   
    mapping(address => mapping(address => bool)) allianceApprovals; // Alliances can approve other users to join their alliance.
    mapping(address => Ally[]) alliances;
    mapping(bytes32 => AssetAction) assetActions;

    mapping(ArmyUnitType => ArmyUnitProperties) armyUnitTypes;

    mapping(uint256 => Army) armies;
    mapping(uint256 => Hero) heroes;

    uint256 structureEventCount;

    Province provinceTemplate;

    BaseSettings baseSettings;
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
