// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity >0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./Commodity.sol";


contract Rock is Initializable, Commodity {

    function initialize(address _game) initializer override public {
        super.initialize(_game);
        __ERC20_init("KingsGold Rock", "KSGR");
    }
}
