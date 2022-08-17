// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface ICommodity is IERC20Upgradeable {
    function spendToTreasury(address from, uint256 amount) external;
    //function mint_with_temp_account(address to, uint256 amount) external;
    function mint(address to, uint256 amount) external; 
}
