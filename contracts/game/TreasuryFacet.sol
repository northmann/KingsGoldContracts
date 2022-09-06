// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../interfaces/ITreasury.sol";
import "../libraries/LibAppStorage.sol";
import "../general/ReentrancyGuard.sol";


// Treasury is a facet of the game that manages the treasury of the game.
contract TreasuryFacet is Game, ITreasury, ReentrancyGuard {


    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor() {
    }

    function buy() payable public override nonReentrant  {
        uint256 amountTobuy = msg.value;
        require(amountTobuy > 0, "You need to send some ether");
        uint256 dexBalance = s.baseSettings.gold.balanceOf(address(this));
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        console.log("Buying ", amountTobuy, " tokens");
        s.baseSettings.gold.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
        console.log("Buy function completed");

    }

    function sell(uint256 amount) public override nonReentrant { 
        require(amount > 0, "You need to sell at least some tokens");
        uint256 allowance = s.baseSettings.gold.allowance(msg.sender, address(this));
        require(allowance >= amount, "Not enough token allowance");
        s.baseSettings.gold.transferFrom(msg.sender, address(this), amount);
        
        payable(msg.sender).transfer(amount); // Withdrawal pattern is needed

        emit Sold(amount);
    }
}
