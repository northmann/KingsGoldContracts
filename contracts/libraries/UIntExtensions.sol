// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library UIntExtensions {

    /// A private function in assembly to count the number of 1's
    /// Ref: https://www.geeksforgeeks.org/count-set-bits-in-an-integer/
    /// @param self The number to be checked.
    /// @return count_ The number of 1s.
    function countOnes(uint256 self) public pure returns (uint256 count_) {
        assembly {
            for { } gt(self, 0) { } {
                self := and(self, sub(self, 1))
                count_ := add(count_, 1)
            }
        }
    }

}
