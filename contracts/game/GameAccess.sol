// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;

import "@openzeppelin/contracts/access/IAccessControl.sol";

import "./Roles.sol";

contract GameAccess {

    modifier requiredRole(bytes32 role) {
        require(IAccessControl(address(this)).hasRole(role, msg.sender),"AccessControl.onlyRole : Access denied");
        _;
    }

}