// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import {LibDiamond} from "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import { IERC173 } from "../interfaces/IERC173.sol";
import { IERC165 } from "../interfaces/IERC165.sol";
import { LibAccessControl } from "../libraries/LibAccessControl.sol";
import { LibRoles } from "../libraries/LibRoles.sol";


import "../libraries/LibAppStorage.sol";
import "../interfaces/IProvinceNFT.sol";
import "../interfaces/IKingsGold.sol";
import "../interfaces/ICommodity.sol";



// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

contract DiamondInit is Game {    

    struct Args {
        address provinceNFT;
        address gold;
        address food;
        address wood;
        address iron;
        address rock;

        uint256 baseGoldCost;
        uint256 provinceLimit;
        uint256 baseProvinceCost;
        uint256 baseCommodityReward;
        uint256 baseUnit;
        uint256 timeBaseCost;
        uint256 goldForTimeBaseCost;
        uint256 foodBaseCost;
        uint256 woodBaseCost;
        uint256 rockBaseCost;
        uint256 ironBaseCost;
        uint256 vassalTribute; // The percentage of asset income vassal pays to the owner of the province.
    }

    // You can add parameters to this function in order to pass in 
    // data to set your own state variables
    function init(Args memory _args) external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        LibAccessControl._grantRole(LibRoles.DEFAULT_ADMIN_ROLE, msg.sender);
        LibAccessControl._grantRole(LibRoles.MINTER_ROLE, msg.sender);
        LibAccessControl._grantRole(LibRoles.UPGRADER_ROLE, msg.sender);
        LibAccessControl._grantRole(LibRoles.CONFIG_ROLE, msg.sender);


        s.provinceNFT = IProvinceNFT(_args.provinceNFT);
        s.gold = IKingsGold(_args.gold);
        s.food = ICommodity(_args.food);
        s.wood = ICommodity(_args.wood);
        s.rock = ICommodity(_args.rock);
        s.iron = ICommodity(_args.iron);
        
        s.baseGoldCost = (_args.baseGoldCost == 0) ? 1 ether : _args.baseGoldCost;
        s.baseUnit = (_args.baseUnit == 0) ? 1 ether : _args.baseUnit;
        s.provinceLimit = (_args.provinceLimit == 0) ? 9 : _args.provinceLimit;
        s.baseProvinceCost = (_args.baseProvinceCost == 0) ? 9 ether : _args.baseProvinceCost;
        s.baseCommodityReward = (_args.baseCommodityReward == 0) ? 100 ether : _args.baseCommodityReward;
        s.timeBaseCost = (_args.timeBaseCost == 0) ? 1 ether : _args.timeBaseCost;
        s.goldForTimeBaseCost = (_args.goldForTimeBaseCost == 0) ? 1 ether : _args.goldForTimeBaseCost;
        s.foodBaseCost = (_args.foodBaseCost == 0) ? 1 ether : _args.foodBaseCost;
        s.woodBaseCost = (_args.woodBaseCost == 0) ? 1 ether : _args.woodBaseCost;
        s.rockBaseCost = (_args.rockBaseCost == 0) ? 1 ether : _args.rockBaseCost;
        s.ironBaseCost = (_args.ironBaseCost == 0) ? 1 ether : _args.ironBaseCost;
        s.vassalTribute = (_args.vassalTribute == 0) ? 50e16 : _args.vassalTribute; // 50%

        // add your own state variables 
        // EIP-2535 specifies that the `diamondCut` function takes two optional 
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface 

        console.log("Initializing diamond completed");
    }


}
