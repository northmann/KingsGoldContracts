// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import {LibDiamond} from "./libraries/LibDiamond.sol";
import {IDiamondCut} from "./interfaces/IDiamondCut.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract Diamond {
    constructor(address _contractOwner, address _diamondCutFacet) payable {
        LibDiamond.setContractOwner(_contractOwner);

        // Add the diamondCut external function from the diamondCutFacet
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        string[] memory functionSignatures = new string[](1);
        
        functionSignatures[0] = "diamondCut((address,string,string[])[],address,bytes)";
        bytes4 selector = bytes4(keccak256(bytes(functionSignatures[0])));

        // console.log("FunctionSignature: diamondCut : %s", iToHex(selector));
        // console.log("IDiamondCut.diamondCut.selector: %s", iToHex(IDiamondCut.diamondCut.selector));

        require(selector == IDiamondCut.diamondCut.selector, "DiamondCutFacet: Incorrect function selector");
        
        cut[0] = IDiamondCut.FacetCut({facetAddress: _diamondCutFacet, facetName: "DiamondCutFacet" , functionSignatures: functionSignatures});

        LibDiamond.diamondCut(cut, address(0), "");
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }
        // get facet from function selector
        LibDiamond.FacetAddressAndPosition memory facetAddressAndPosition = ds.selectorToFacetAndPosition[msg.sig];
        address facetAddress = facetAddressAndPosition.facetAddress;
        require(
            facetAddress != address(0),
            string(
                abi.encodePacked(
                    "Diamond: Function does not exist: ", iToHex(msg.sig), 
                    " - msg.sender: ", Strings.toHexString(msg.sender),
                    " - tx.origin: ", Strings.toHexString(tx.origin) 
                    )
            )
        );

        // Hardhat do not log the name of the function called when using delegateCall
        console.log("Function call: %s - on Facet: %s", facetAddressAndPosition.functionName, facetAddressAndPosition.facetName);

        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facetAddress, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}

    function iToHex(bytes4 buffer) internal pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(abi.encodePacked("0x", converted));
    }

    function bytes20ToLiteralString(bytes20 data) private pure returns (string memory result) {
        bytes memory temp = new bytes(41);
        uint256 count;

        for (uint256 i = 0; i < 20; i++) {
            bytes1 currentByte = bytes1(data << (i * 8));

            uint8 c1 = uint8(bytes1((currentByte << 4) >> 4));

            uint8 c2 = uint8(bytes1((currentByte >> 4)));

            if (c2 >= 0 && c2 <= 9) temp[++count] = bytes1(c2 + 48);
            else temp[++count] = bytes1(c2 + 87);

            if (c1 >= 0 && c1 <= 9) temp[++count] = bytes1(c1 + 48);
            else temp[++count] = bytes1(c1 + 87);
        }

        result = string(temp);
    }
}
