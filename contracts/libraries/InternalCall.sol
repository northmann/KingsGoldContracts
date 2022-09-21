// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";


/******************************************************************************\
* Author: Northmann
/******************************************************************************/
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import "./LibDiamond.sol";

library InternalCall {
    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    bytes32 constant InternalCallGuard_STORAGE_POSITION = keccak256("InternalCallGuard.guardStorage");

    struct GuardStorage {
        uint256 status; // 0 = not entered, 1 = entered
    }

    function guardStorage() internal pure returns (GuardStorage storage ds) {
        bytes32 position = InternalCallGuard_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    modifier setInternalCall() {
        setInternalCallBefore();
        _;
        setInternalCallAfter();
    }


    function checkInternalCall() internal view {
        GuardStorage storage guard = guardStorage();
        // Need to be "entered" to call this function
        require(guard.status == _ENTERED, "InternalCallGuard: call needs to be an internal");
    }

    function setInternalCallBefore() internal {
        GuardStorage storage guard = guardStorage();
        // On the first call to setInternalCall, _notEntered will be true
        require(guard.status != _ENTERED, "InternalCallGuard: re-call not allowed");

        // Any calls to setInternalCall after this point will fail
        guard.status = _ENTERED;
    }

    function setInternalCallAfter() internal {
        GuardStorage storage guard = guardStorage();
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        guard.status = _NOT_ENTERED;
    }

    // Calls a function from the diamond that is public but only callable from within the diamond
    function delegateCall(bytes memory _calldata) internal setInternalCall {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        bytes4 sig = bytes4(_calldata);

        // get facet from function selector
        LibDiamond.FacetAddressAndPosition memory facetAddressAndPosition = ds.selectorToFacetAndPosition[sig];
        address facetAddress = facetAddressAndPosition.facetAddress;
        require(facetAddress != address(0),string(abi.encodePacked("Diamond: Function does not exist: ", iToHex(sig))));

        // Hardhat do not log the name of the function called when using delegateCall
        console.log("Internal call: %s - on Facet: %s", facetAddressAndPosition.functionName, facetAddressAndPosition.facetName);

        (bool success, bytes memory ret) = facetAddress.delegatecall(_calldata); // callData is a result of abi.encodeWithSignature(func, args)
        require(success, string(ret));
    }

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
}
