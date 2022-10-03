// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Source: https://solidity-by-example.org/library/
import "./UIntExtensions.sol";

library Math {
    using UIntExtensions for uint256;

    function addPseudoGaussian(uint256 _hits, uint256 _diceRolls) public view returns (uint256 totalHit_) {
        totalHit_ = _hits;
        uint256 median = (_diceRolls > 256) ? 256 / 2 : _diceRolls / 2;

        // Generates a NOT cryptographically secure pseudo random number
        uint256 r = uint256(keccak256(abi.encodePacked(_hits, block.timestamp, blockhash(block.number - 1))));

        if (_diceRolls < 256) r = r << (256 - _diceRolls);

        uint256 ones = r.countOnes();
        uint256 diff = (ones >= median) ? ones - median : median - ones;
        uint256 gaussianPercent = (diff * 100) / median;

        uint256 hitDiff = (_hits * gaussianPercent) / 100;

        if (ones >= median) totalHit_ += hitDiff;
        else totalHit_ -= hitDiff;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0 (default value)
    }
}
