"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const config_1 = require("hardhat/config");
(0, config_1.task)("getUser", "Prints an user json data")
    .addParam("contract", "The contract's address")
    .addParam("account", "The account's address")
    .setAction(async (taskArgs, hre) => {
    const contract = await hre.ethers.getContractAt('UserFacet', taskArgs.contract);
    const user = await contract.getUser(taskArgs.account);
    console.log(user);
});
//# sourceMappingURL=userFacet%20copy.js.map