// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IGenericNFT is IERC721Upgradeable {
    function mint(address to) external returns(uint256);
}
