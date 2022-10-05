// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../interfaces/IKingsGold.sol";
import "../interfaces/IProvinceNFT.sol";
import "../interfaces/ICommodity.sol";
import "../game/AccessControlFacet.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

uint256 constant maxPower = 1000; // Max value of a unit.
uint256 constant ArmyUnitTypeCount = 6;



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
    
    //uint256[] provinces;
    //uint256[] armyList;

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
    Garrison,
    Moving,
    Last
}


struct ArmyUnitProperties {
    ArmyUnitType armyUnitTypeId;

    uint128 openAttack;
    uint128 openDefence;
    uint128 seigeAttack;
    uint128 seigeDefence;
    uint128 speed;  // Catapult 100, Archer 200, Knight 300, Soldier 200, Militia 0 (militia never leaves the province)
    uint128 priority;
    
}


struct ArmyUnit {
    ArmyUnitType armyUnitTypeId;
    uint256 amount;
    uint256 shares;
}

struct BattleUnit {
    ArmyUnitType armyUnitTypeId;
    ArmyUnitProperties armyUnitProperties;
    ArmyUnit attack;
    ArmyUnit defence;
}

struct BattleHit {
    ArmyUnitType armyUnitTypeId;
    uint256 attackHit;
    uint256 defenceHit;
}

struct BattleRound {
    uint256 id;
    uint256 totalAttackHit;
    uint256 totalDefenceHit;

    uint256 totalAttackUnits;
    uint256 totalDefenceUnits;
    
    int256 attackDeviation;
    int256 defenceDeviation;

    BattleHit[ArmyUnitTypeCount] hits;
}

struct Battle {
    ArmyState defendingState;

    BattleUnit[ArmyUnitTypeCount] units;
    BattleRound[] rounds;
}

struct Army {
    uint256 id;
    ArmyState state;
   
    uint256 hero; // TokenId of the hero NFT.

    address owner; // The owner of the army.
    
    uint256 provinceId; // The province the army is currently in or moving to.
    uint256 departureProvinceId; // The province the army is moving from. 

    uint256 startTime;
    uint256 endTime;

    //string name; // The name of the army. Auto generated if not set. Use hero?
}


struct Position {
    uint128 x;
    uint128 y;
}

struct Province {
    uint256 id;
    string name;
    address owner;
    address vassal;
    Position position;

    uint64 plains; // Food
    uint64 forest; // Wood
    uint64 mountain; // Stone
    uint64 hills; // Gold and iron ore

    uint256 populationTotal;
    uint256 populationAvailable;
    uint256 garrisonId;
    uint256 deposit; // The amount of gold deposited in the province. This gold is claimable by the owner when the province is destroyed.
    uint256 vassalFee;
    uint256 level; // The level of the province. This is the level of the highest structure in the province.
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
    mapping(address => EnumerableSet.UintSet) userProvinces;
    EnumerableSet.AddressSet userList; // All users in the system.

    mapping(address => UserCheckpoint) userCheckpoint;

    mapping(uint256 => Province) provinces; // Provinces are indexed by the ID from the ProvinceNFT contract
    EnumerableSet.UintSet provinceList; // All provinces in the system.

    mapping(uint256 => ProvinceCheckpoint) provinceCheckpoint; // Provinces are indexed by the ID from the ProvinceNFT contract
    mapping(AssetType => Asset) assets; // Assets are indexed by the AssetType enum.
    mapping(uint256 => mapping(AssetType => Structure)) structures; // ProvinceID => StructureID (AssetTypeId) => Structure

    
    mapping(uint256 => StructureEvent) structureEvents; // Structure events are indexed by the user who created the event.
    mapping(uint256 => EnumerableSet.UintSet) provinceStructureList; // ProvinceID => StructureID (AssetTypeId) 
    mapping(uint256 => EnumerableSet.UintSet) provinceActiveStructureTaskList; // All active structure events for a user.
    mapping(uint256 => EnumerableSet.UintSet) provinceStructureTaskList; // All structure events for a user.
   
    mapping(address => mapping(address => bool)) allianceApprovals; // Alliances can approve other users to join their alliance.
    mapping(address => Ally[]) alliances;
    mapping(bytes32 => AssetAction) assetActions;

    mapping(ArmyUnitType => ArmyUnitProperties) armyUnitTypes;

    mapping(uint256 => EnumerableSet.UintSet) provinceArmies; // The armies in a province. This includes the garrison, arriving, and idle armies.
    mapping(uint256 => EnumerableSet.UintSet) departureArmies; // The departure armies in a province. Index is province.id
    mapping(address => EnumerableSet.UintSet) userArmies; // The armies owned by the user. Index is owner address
    mapping(address => EnumerableSet.UintSet) userShareArmies; // The target armies that a user has shares in. Index is owner address.

    mapping(uint256 => Army) armies;
    mapping(uint256 => Hero) heroes;
    mapping(uint256 => mapping(ArmyUnitType => ArmyUnit)) armyUnits; // The units of an army. Index is army.id & ArmyUnitType
    mapping(address => mapping(uint256 => mapping(ArmyUnitType => ArmyUnit))) armyShareUnits; // The share units of an army. Index is user address & army.id & ArmyUnitType


    uint256 structureEventCount;
    uint256 armyCount;

    Province provinceTemplate;

    BaseSettings baseSettings;
}

