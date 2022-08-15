// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MultiCallFacet is ReentrancyGuard {

    event CallResult(bool success, bytes4 sig, bytes result);

    // @author Northmann
    // @dev Executes a series of function calls that can change state. 
    // @param _calls The calls to be executed.
    function callFunctions(bytes[] calldata calls) external payable nonReentrant {
        // Prevents a malicious contract from calling on behalf of the origin caller.
        require(msg.sender == tx.origin, "callFunctions can only be called directly and not by a proxy");

        for(uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = address(this).delegatecall(calls[i]); // callData is a result of abi.encodeWithSignature(func, args)
            
            // Return the results as events as the values are not available in the return data directly.
            // Values are available after the mining of a block.
            emit CallResult(success, bytes4(calls[i]), ret); 
        }
    }

}
