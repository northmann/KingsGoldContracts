// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./RemoteGameAccessControl.sol";
import "../game/Roles.sol";
import "../interfaces/ICommodity.sol";


// Minimal change-----
// Roles added
// GenericAccessControl added
contract Commodity is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, Roles, RemoteGameAccessControl, UUPSUpgradeable, ICommodity {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _game) initializer virtual public {
        __setGame(_game);
        __ERC20_init("KingsGold Commodity", "KSGC");
        __ERC20Burnable_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
    }

    // The SPENDER_ROLE are typically only given to Province contracts.
    // modifier onlySpender() {
    //     require(userAccountManager.hasRole(SPENDER_ROLE, msg.sender), "Caller do not have the SPENDER_ROLE");
    //     _;
    // }

    // Allow a contract to call this function and transfer on behalf of the original caller.
    // This function ignores allowances.
    function spendToTreasury(uint256 amount) public override onlyGame {
        // Spend from the original caller by a contract with the SPENDER_ROLE.
        _transfer(tx.origin, game, amount);
    }

    function mint(address to, uint256 amount) public override onlyGame {
        _mint(to, amount);
    }

    // function setTreasury(ITreasury _treasury) public onlyRole(DEFAULT_ADMIN_ROLE) {
    //     treasury = _treasury;
    // }

    // function mint_with_temp_account(address to, uint256 amount) public override onlyRole(TEMPORARY_MINTER_ROLE) {
    //     _mint(to, amount);
    // }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}