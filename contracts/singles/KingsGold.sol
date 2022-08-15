// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "./RemoteGameAccessControl.sol";

contract KingsGold is ERC20, ERC20Burnable, RemoteGameAccessControl {

    constructor(address _game) ERC20("KingsGold", "KSG") {
        __setGame(_game);
    }

    function mint(address to, uint256 amount) public onlyGame {
        _mint(to, amount);
    }
}