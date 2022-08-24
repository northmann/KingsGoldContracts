// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IKingsGold is IERC20 {
    function mint(address to, uint256 amount) external;
    function approveFrom(address from, uint256 amount) external;
}
