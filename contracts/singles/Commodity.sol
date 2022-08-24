// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./RemoteGameAccessControl.sol";
import "../interfaces/ICommodity.sol";

import { LibRoles } from "../libraries/LibRoles.sol";


// Minimal change-----
// Roles added
// GenericAccessControl added
abstract contract Commodity is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, RemoteGameAccessControl, UUPSUpgradeable, ICommodity {

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

    // Allow the game to call this function and transfer on behalf of the original caller.
    // This function ignores allowances.
    function spendToTreasury(address from, uint256 amount) public override onlyGame {
        // Spend from the original caller by a contract with the SPENDER_ROLE.
        _transfer(from, game, amount);
    }

    function mint(address to, uint256 amount) public override onlyGame {
        _mint(to, amount);
    }

    function approveFrom(address from, uint256 amount) public override onlyGame {
        _approve(from, game, amount);
    }

    function pause() public onlyRole(LibRoles.PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(LibRoles.PAUSER_ROLE) {
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
        onlyRole(LibRoles.UPGRADER_ROLE)
        override
    {}
}