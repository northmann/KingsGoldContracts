// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";


import "../interfaces/IKingsGold.sol";
import "../interfaces/IProvinceNFT.sol";
import "../interfaces/ICommodity.sol";


//import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";

enum State {
    Active,
    PaidFor,
    Minted,
    Completed,
    Cancelled
}

struct ResourceFactor {
    uint256 manPower;
    uint256 attrition;
    uint256 penalty;
    uint256 time;
    uint256 goldForTime;
    uint256 food;
    uint256 wood;
    uint256 rock;
    uint256 iron;
}



struct Structure {
    uint256 typeId;
    uint256 availableAmount;
    uint256 totalAmount;
}

struct Event{
    State state;

    uint256 itemId;

    uint256 costIndex;
    uint256 rewardIndex;

    uint256 creationTime;
    uint256 timeRequired;
    uint256 goldForTime;
    uint256 attrition;

    // The cost of resources for this event
    address hero;

    uint256 timeBaseCost;
    uint256 goldForTimeBaseCost;
    uint256 foodBaseCost;

    uint256 multiplier; // Multiply the effect of the event. More Farms create more yield etc.
    uint256 penalty; // The penalty factor for cancelling the event, if any.
    uint256 rounds; // Repeat the event a number of rounds.
    uint256 manPower;
    uint256 foodAmount;
    uint256 woodAmount;
    uint256 rockAmount;
    uint256 ironAmount;
    address receiver;
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

    uint256[] eventList;

    uint256[] structureList;
}

struct User {
    //EnumerableSet.AddressSet provinces;
    uint256[] provinces;

    address kingdom;
    address alliance;
}

struct AppStorage {
    mapping(address => User) users;
    address[] userList;

    mapping(uint256 => Province) provinces;    // Provinces are indexed by the ID from the ProvinceNFT contract
    uint256[] provinceList;

    mapping(uint256 => Structure) structures;

    mapping(uint256 => Event) events;

    mapping(address => uint256[]) eventList;


    uint256 provinceLimit;
    uint256 baseProvinceCost;
    uint256 baseCommodityReward;
    
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
