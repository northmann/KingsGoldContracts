"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const config_1 = require("hardhat/config");
const army_1 = require("../army");
(0, config_1.task)("getArmy", "Get army data")
    .addParam("diamond", "The contract's address")
    .addParam("id", "The gold amount in ethers")
    .setAction(async (taskArgs, hre) => {
    const contract = await hre.ethers.getContractAt('ArmyFacet', taskArgs.diamond);
    const army = await contract.getArmy(taskArgs.id);
    console.log(army);
});
(0, config_1.task)("setAppStoreArmyUnitTypes", "Deploys the ArmyUnitTypes")
    .addParam("diamond", "The diamond's address")
    .setAction(async (taskArgs, hre) => {
    const contract = await hre.ethers.getContractAt('ConfigurationFacet', taskArgs.diamond);
    const arr = (0, army_1.getArmyUnitTypeRawData)();
    console.log("Deploying ArmyUnitType RawData...");
    let tx = await contract.setAppStoreArmyUnitTypes(arr);
    await tx.wait();
    console.log("Deployed", arr.length, "ArmyUnitTypes");
});
//# sourceMappingURL=armyFacet.js.map