// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.4;
import "hardhat/console.sol";

import "../libraries/LibAppStorage.sol";
import "../libraries/LibMeta.sol";


contract Game {
    AppStorage internal s;

    function msgSender() internal view returns (address sender_) {
        sender_ = LibMeta.msgSender();
    }
    

}
