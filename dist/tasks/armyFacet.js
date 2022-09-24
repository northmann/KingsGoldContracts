"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProvinceArmies = void 0;
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
// --------------------------------------------------------------------------------------------
(0, config_1.task)("getProvinceArmies", "Get army data")
    .addParam("diamond", "The contract's address")
    .addParam("provinceid", "The ID of the province")
    .setAction(async (taskArgs, hre) => {
    let armies = await getProvinceArmies(hre, taskArgs.diamond, taskArgs.provinceid);
    console.log(armies);
    return armies;
});
async function getProvinceArmies(hre, diamondAddress, provinceId) {
    const contract = await hre.ethers.getContractAt('ArmyFacet', diamondAddress);
    const armies = await contract.getProvinceArmies(provinceId);
    return armies;
}
exports.getProvinceArmies = getProvinceArmies;
// --------------------------------------------------------------------------------------------
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
// --------------------------------------------------------------------------------------------
(0, config_1.task)("updateGarrison", "Deploys the ArmyUnitTypes")
    .addParam("diamond", "The diamond's address")
    .addParam("provinceid", "The ID of the province")
    .setAction(async (taskArgs, hre) => {
    const contract = await hre.ethers.getContractAt('ArmyFacet', taskArgs.diamond);
    const arr = [
        {
            armyUnitTypeId: army_1.ArmyUnitType.Militia,
            amount: 10,
        },
        {
            armyUnitTypeId: army_1.ArmyUnitType.Soldier,
            amount: 12,
        },
        {
            armyUnitTypeId: army_1.ArmyUnitType.Archer,
            amount: 8,
        },
        {
            armyUnitTypeId: army_1.ArmyUnitType.Knight,
            amount: 3,
        },
        {
            armyUnitTypeId: army_1.ArmyUnitType.Catapult,
            amount: 1,
        },
    ];
    console.log("Deploying garrison test data...");
    let tx = await contract.updateGarrison(taskArgs.provinceid, arr);
    await tx.wait();
    console.log("Deployed", arr.length, "ArmyUnits");
});
//# sourceMappingURL=armyFacet.js.map