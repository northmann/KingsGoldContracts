// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;


library LibRoles {

        // Constants is imbedded into the bytecode.
    bytes32 internal constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 internal constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 internal constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 internal constant VASSAL_ROLE = keccak256("VASSAL_ROLE");
    bytes32 internal constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 internal constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 internal constant PROVINCE_ROLE = keccak256("PROVINCE_ROLE");
    bytes32 internal constant EVENT_ROLE = keccak256("EVENT_ROLE");
    bytes32 internal constant TEMPORARY_MINTER_ROLE = keccak256("TEMPORARY_MINTER_ROLE");
    bytes32 internal constant ARMY_ROLE = keccak256("ARMY_ROLE");
    bytes32 internal constant MULTICALL_ROLE = keccak256("MULTICALL_ROLE");
    bytes32 internal constant SPENDER_ROLE = keccak256("SPENDER_ROLE");
    bytes32 internal constant CONFIG_ROLE = keccak256("CONFIG_ROLE");

}