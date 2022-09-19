"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const config_1 = require("hardhat/config");
(0, config_1.task)("owner", "Get the owner of the diamond")
    .addParam("diamond", "Address of the Diamond to upgrade")
    .setAction(async (taskArgs, hre) => {
    const diamondAddress = taskArgs.diamond;
    const ownershipFacet = await hre.ethers.getContractAt("OwnershipFacet", diamondAddress);
    const owner = await ownershipFacet.owner();
    console.log(owner);
});
//# sourceMappingURL=ownershipFacet.js.map