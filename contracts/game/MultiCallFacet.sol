// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "hardhat/console.sol";

//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MultiCallFacet  {

    event CallResult(bool success, bytes4 sig, bytes result);

    struct Call {
        address target;
        bytes callData;
    }
    struct Result {
        bool success;
        bytes returnData;
    }

    // @dev Modified for the Diamond pattern.
    // @dev useDapp uses the original contract owner as msg.sender and not the address of the caller.
    function aggregate(Call[] memory calls) public returns (uint256 blockNumber, bytes[] memory returnData) {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        for(uint256 i = 0; i < calls.length; i++) {
            
            address target = calls[i].target;
            //console.log("MultiCallFacet.aggregate - target: %s - address(this): %s - msg.sender: %s", target, address(this), msg.sender);
            if(target == address(this)) {
                // Call target is this contract, so we use delegatecall as the data in on this contract.
                (bool success, bytes memory ret) = target.delegatecall(calls[i].callData);
                require(success, "Multicall aggregate: call failed");
                returnData[i] = ret;

            } else {
                // Call target is not this contract, so we need to use the call mechanism as the data is on target contract.
                (bool success, bytes memory ret) = target.call(calls[i].callData);
                require(success, "Multicall aggregate: call failed");
                returnData[i] = ret;
            }
        }
    }
    function blockAndAggregate(Call[] memory calls) public returns (uint256 blockNumber, bytes32 blockHash, Result[] memory returnData) {
        (blockNumber, blockHash, returnData) = tryBlockAndAggregate(true, calls);
    }
    function getBlockHash(uint256 blockNumber) public view returns (bytes32 blockHash) {
        blockHash = blockhash(blockNumber);
    }
    function getBlockNumber() public view returns (uint256 blockNumber) {
        blockNumber = block.number;
    }
    function getCurrentBlockCoinbase() public view returns (address coinbase) {
        coinbase = block.coinbase;
    }
    function getCurrentBlockDifficulty() public view returns (uint256 difficulty) {
        difficulty = block.difficulty;
    }
    function getCurrentBlockGasLimit() public view returns (uint256 gaslimit) {
        gaslimit = block.gaslimit;
    }
    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {
        timestamp = block.timestamp;
    }
    function getEthBalance(address addr) public view returns (uint256 balance) {
        balance = addr.balance;
    }
    function getLastBlockHash() public view returns (bytes32 blockHash) {
        blockHash = blockhash(block.number - 1);
    }
    function tryAggregate(bool requireSuccess, Call[] memory calls) public returns (Result[] memory returnData) {
        returnData = new Result[](calls.length);
        for(uint256 i = 0; i < calls.length; i++) {

            address target = calls[i].target;

            //console.log("MultiCallFacet.tryAggregate - target: %s - address(this): %s - msg.sender: %s", target, address(this), msg.sender);

            if(target == address(this)) {
                // Call target is this contract, so we use delegatecall as the data in on this contract.
                (bool success, bytes memory ret) = target.delegatecall(calls[i].callData);
                if (requireSuccess) {
                    require(success, "Multicall2 aggregate: call failed");
                }

                returnData[i] = Result(success, ret);

            } else {
                // Call target is not this contract, so we need to use the call mechanism as the data is on target contract.
                (bool success, bytes memory ret) = target.call(calls[i].callData);
                if (requireSuccess) {
                    require(success, "Multicall2 aggregate: call failed");
                }
                returnData[i] = Result(success, ret);
            }
        }
    }
    function tryBlockAndAggregate(bool requireSuccess, Call[] memory calls) public returns (uint256 blockNumber, bytes32 blockHash, Result[] memory returnData) {
        blockNumber = block.number;
        blockHash = blockhash(block.number);
        returnData = tryAggregate(requireSuccess, calls);
    }

    // @author Northmann
    // @dev Executes a series of function calls that can change state. 
    // @dev Designed to only work with the Diamond pattern on the same on contract.
    // @param _calls The calls to be executed.
    function callFunctions(bytes[] calldata calls) external payable  {
        // Prevents a malicious contract from calling on behalf of the origin caller.
        require(msg.sender == tx.origin, "callFunctions can only be called directly and not by a proxy");

        //console.log("MultiCallFacet.callFunctions - msg.sender: %s", msg.sender);

        for(uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = address(this).delegatecall(calls[i]); // callData is a result of abi.encodeWithSignature(func, args)
            
            // Return the results as events as the values are not available in the return data directly.
            // Values are available after the mining of a block.
            emit CallResult(success, bytes4(calls[i]), ret); 
        }
    }

}
