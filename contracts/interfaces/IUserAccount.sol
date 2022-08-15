// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;

import "./IProvince.sol";

interface IUserAccount {
    function provinceCount() external view returns(uint256);
    function addProvince(IProvince _province) external;
    function removeProvince(address _province) external;
    function getProvince(uint256 index) external returns(address);
    function getProvinces() external view returns(address[] memory);
    function setKingdom(address _kingdomAddress) external;
    function setAlliance(address _kingdomAddress) external;
}
