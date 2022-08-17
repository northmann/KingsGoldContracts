// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;

interface IEvent { 
    function typeId() external pure returns(uint256);
    function multiplier() external returns(uint256);
    function penalty() external returns(uint256);
    function rounds() external returns(uint256);
    function manPower() external returns(uint256);
    function foodAmount() external returns(uint256);
    function woodAmount() external returns(uint256);
    function rockAmount() external returns(uint256);
    function ironAmount() external returns(uint256);

    function priceForTime() external returns(uint256);
    function payForTime() external;
    function paidForTime() external;

    function complete() external;
    function cancel() external;
}
