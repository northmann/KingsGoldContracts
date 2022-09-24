"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.approveGold = exports.buyGold = void 0;
const config_1 = require("hardhat/config");
const utils_1 = require("../lib/utils");
const utils_2 = require("ethers/lib/utils");
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
    .addParam("diamond", "The diamond address")
    .addParam("amount", "The amount in ethers")
    .addFlag("useledger", "Set to true if Ledger should be used for signing")
    .setAction(async (taskArgs, hre) => {
    //Instantiate the Signer
    let signer = await (0, utils_1.getSigner)(hre, taskArgs.diamond, taskArgs.useledger);
    const value = (0, utils_2.parseUnits)(taskArgs.amount.toString(), 18); // 100
    buyGold(hre, taskArgs.diamond, signer, value);
    //setBalance(hre, signer, taskArgs.amount);
});
async function buyGold(hre, diamondAddress, signer, amount) {
    let treasuryFacet = await hre.ethers.getContractAt('TreasuryFacet', diamondAddress, signer);
    let tx = await treasuryFacet.buy({ value: amount });
    await tx.wait();
}
exports.buyGold = buyGold;
// --------------------------------------------------------------------------------------------
(0, config_1.task)("approveGold2", "Approve gold")
    .addParam("diamond", "The diamond address. The diamond knows the gold contract address")
    .addParam("amount", "The amount in ethers")
    .addFlag("useledger", "Set to true if Ledger should be used for signing")
    .setAction(async (taskArgs, hre) => {
    //Instantiate the Signer
    let signer = await (0, utils_1.getSigner)(hre, taskArgs.diamond, taskArgs.useledger);
    const value = (0, utils_2.parseUnits)(taskArgs.amount.toString(), 18); // 100
    approveGold(hre, taskArgs.diamond, signer, value);
    //setBalance(hre, signer, taskArgs.amount);
});
async function approveGold(hre, diamondAddress, signer, amount) {
    let settingsContract = await hre.ethers.getContractAt('ConfigurationFacet', diamondAddress, signer);
    let settings = await settingsContract.getBaseSettings();
    // Approve the diamond contract to spend the gold
    let userGoldInstance = await hre.ethers.getContractAt('KingsGold', settings.gold, signer);
    let approveTx = await userGoldInstance.approve(diamondAddress, amount);
    await approveTx.wait();
}
exports.approveGold = approveGold;
// --------------------------------------------------------------------------------------------
//# sourceMappingURL=treasuryFacet.js.map