// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;

import "@openzeppelin/contracts/access/IAccessControl.sol";


interface IGenericAccessControl is IAccessControl {
    function game() external view returns(IGenericAccessControl game_);
}
