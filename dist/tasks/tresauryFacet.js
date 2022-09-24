"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const config_1 = require("hardhat/config");
const utils_1 = require("../lib/utils");
// --------------------------------------------------------------------------------------------
(0, config_1.task)("setEthBalance", "Set the eth balance of an account")
    .addParam("account", "The account's address")
    .addParam("amount", "The amount in ethers")
    .addFlag("useledger", "Set to true if Ledger should be used for signing")
    .setAction(async (taskArgs, hre) => {
    //Instantiate the Signer
    let signer = await (0, utils_1.getSigner)(hre, taskArgs.account, taskArgs.useledger);
    (0, utils_1.setBalance)(hre, signer, taskArgs.amount);
});
// --------------------------------------------------------------------------------------------
(0, config_1.task)("buyGold", "Buy gold from the treasury")
    .addParam("account", "The account's address")
    .addParam("amount", "The amount in ethers")
    .addFlag("useledger", "Set to true if Ledger should be used for signing")
    .setAction(async (taskArgs, hre) => {
    //Instantiate the Signer
    let signer = await (0, utils_1.getSigner)(hre, taskArgs.account, taskArgs.useledger);
    (0, utils_1.setBalance)(hre, signer, taskArgs.amount);
});
//# sourceMappingURL=tresauryFacet.js.map