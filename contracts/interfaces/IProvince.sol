// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;

//import "@openzeppelin/contracts/access/IAccessControl.sol";

interface IProvince  { 
    // function latestEvent() external view returns(IEvent);
    // function getEvents() external view returns(EventListExtensions.ActionEvent[] memory);
    // function continent() external view returns(IContinent);
    // function setVassal(address _user) external;
    // function removeVassal(address _user) external;

    // function populationTotal() external view returns(uint256);
    // function populationAvailable() external view returns(uint256);
    // function setPopulationTotal(uint256 _count) external;
    // function setPopulationAvailable(uint256 _count) external;

    // function createStructureEvent(uint256 _structureId, uint256 _multiplier, uint256 _rounds, uint256 _hero) external;
    // function createYieldEvent(uint256 _structureId, uint256 _multiplier, uint256 _rounds, uint256 _hero) external;
    // function createGrowPopulationEvent(uint256 _rounds, uint256 _manPower, uint256 _hero) external returns(IPopulationEvent);

    // function findActiveEventIndex(address _addr) external view returns(uint256);
    // function addActiveEvent(address _addr, uint256 _typeId, uint256 _itemId, uint256 timestamp) external;
    // function updateActiveEvent(uint256 _index, uint256 _itemId, uint256 timestamp) external;
    // function removeActiveEvent(uint256 _index) external; 
    // function archiveEvent(uint256 _index) external;

    // function completeMint(IYieldEvent _event) external;

    // function getStructure(uint256 _id) external returns(bool, address);
    // function setStructure(uint256 _id, IStructure _structureContract) external;
    // function payForTime(IEvent _event) external;
    // function completeEvent(IEvent _event) external;
    // function cancelEvent(IEvent _event) external;
    // function world() external view returns(IWorld);
    // function containsEvent(IEvent _event) external view returns(bool);
    // function getAttributes() external returns (
    //     string memory Name,
    //     address Owner,
    //     address Vassal,

    //     uint32 PositionX,
    //     uint32 PositionY,

    //     uint32  Plains,   // Food
    //     uint32  Forest,   // Wood
    //     uint32  Mountain, // Stone
    //     uint32  Hills,   // Gold and iron ore

    //     uint256 PopulationTotal,
    //     uint256 PopulationAvailable,
    //     address ArmyContract
    //     );
}
