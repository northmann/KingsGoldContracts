// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "../libraries/AppStorage.sol";
import "../libraries/AppStorageExtensions.sol";
import "../general/Game.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract UserFacet is Game {
    using AppStorageExtensions for AppStorage;
    using EnumerableSet for EnumerableSet.AddressSet;

    constructor() {
    }


    // --------------------------------------------------------------
    // View Functions
    // --------------------------------------------------------------

    function getUser(address _user) external view returns (User memory) {
        return s.getUser(_user);
    }

    function getUsers() external view returns (User[] memory users_) {
        address[] memory userIds = s.userList.values();
        users_ = new User[](userIds.length);

        for(uint256 i = 0; i < userIds.length; i++) {
            users_[i] = s.users[userIds[i]];
        }
    }


    // --------------------------------------------------------------
    // External Functions
    // --------------------------------------------------------------

    function setKingdom() external {
        User storage user = s.users[msg.sender];
        if(user.kingdom == address(0)) {
            user.kingdom = msg.sender;
        }
    }

    error UserNotApprovedToJoinAlliance(address _alliance);

    function allianceApprove(address _user) external {
        require(_user == address(0), "Target is address(0)");
        s.allianceApprovals[msg.sender][_user] = true;
    }

    function isAllianceApproved(address _alliance) public view returns (bool approved) {
        approved = s.allianceApprovals[_alliance][msg.sender];
    }

    function addAlliance(address _alliance) external {
        User storage user = s.users[msg.sender];
        require(user.alliance == address(0), "User already has an alliance");

        if(s.allianceApprovals[_alliance][msg.sender] == true) {
            
            Ally memory ally = Ally({
                user:msg.sender,
                status: 1
            });
            s.alliances[_alliance].push(ally);

            user.alliance = _alliance;
            user.allianceIndex = s.alliances[_alliance].length; // Offset by 1 to account for 0 index as empty.

        } else {
            revert UserNotApprovedToJoinAlliance(_alliance);
        }
    }

    function removeAlliance(address _alliance) external {
        User storage user = s.users[msg.sender];
        require(user.alliance != address(0), "User does not have an alliance");
        require(user.allianceIndex != 0, "User does not have an alliance index");

        Ally[] storage allies = s.alliances[_alliance];
        require(allies[user.allianceIndex-1].user == msg.sender, "User is not a part the alliance");

        allies[user.allianceIndex-1] = allies[allies.length-1];
        allies.pop();

        user.alliance = address(0);
        user.allianceIndex = 0;
    }



}
