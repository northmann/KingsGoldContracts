// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;

struct RoleData {
    mapping(address => bool) members;
    bytes32 adminRole;
}

struct AccessStorage {
    mapping(bytes32 => RoleData) roles;
}

library LibAccessControl {
    bytes32 constant internal ACCESS_STORAGE_POSITION = keccak256("AccessControl.accessStorage");

    function accessStorage() internal pure returns (AccessStorage storage ds) {
        bytes32 position = ACCESS_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal {
        AccessStorage storage ds = accessStorage();
        ds.roles[role].members[account] = true;
    }


}