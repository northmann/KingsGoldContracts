// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/access/IAccessControl.sol";

import "../game/Roles.sol";

contract RemoteGameAccessControl is Roles {

    address public game;

    modifier onlyGame() {
        require(game == msg.sender,"Caller is not the Game");
        _;
    }

    modifier onlyRole(bytes32 role) {
        require(IAccessControl(game).hasRole(role, msg.sender),"GenericAccessControl.onlyRole : Access denied");
        _;
    }

    modifier onlyRoles(bytes32 role1, bytes32 role2) {
        require(IAccessControl(game).hasRole(role1, msg.sender) || IAccessControl(game).hasRole(role2, msg.sender),"GenericAccessControl.onlyRoles : Access denied");
        _;
    }


    function setGame(address _game) public onlyRole(DEFAULT_ADMIN_ROLE) { 
        __setGame(_game);
    }

    function __setGame(address _game) internal {
        game = _game;
    }

}