// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;

import "./IKingsGold.sol";

interface ITreasury {
    function buy() payable external;
    function sell(uint256 amount) external;
}
