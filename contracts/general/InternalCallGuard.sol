// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "../libraries/InternalCall.sol";

// Only allow internal calls
abstract contract InternalCallGuard {

    modifier onlyInternalCall() {
        InternalCall.checkInternalCall();
        _;
    }


}