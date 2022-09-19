"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const config_1 = require("hardhat/config");
const utils_1 = require("../lib/utils");
(0, config_1.task)("deployFacet", "deploy a facet")
    .addParam("diamond", "The diamond address")
    .addParam("facet", "The contract's name")
    .addFlag("useledger", "Set to true if Ledger should be used for signing")
    .setAction(async (taskArgs, hre) => {
    console.log("Logon taskArgs: ", taskArgs);
    const diamondAddress = taskArgs.diamond;
    const facetName = taskArgs.facet;
    const useLedger = taskArgs.useledger;
    //Instantiate the Signer
    let signer = await (0, utils_1.getSigner)(hre, diamondAddress, useLedger);
    //const feeData = await hre.ethers.provider.getFeeData();
    //console.log(`feeData: `, feeData);
    const Contract = await hre.ethers.getContractFactory(facetName, signer);
    const facet = await Contract.deploy(); // {gasPrice: feeData.gasPrice}
    await facet.deployed();
    console.log("Facet deployed to: ", facet.address);
    let cut = [];
    cut.push({
        facetAddress: facet.address,
        facetName: facetName,
        functionSignatures: (0, utils_1.getFunctionSignatures)(facet)
    });
    console.log(cut);
    const diamondCut = await hre.ethers.getContractAt('IDiamondCut', diamondAddress, signer);
    // call to init function
    let tx = await diamondCut.diamondCut(cut, hre.ethers.constants.AddressZero, "0x"); // , { gasLimit: 30000000}
    let receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }
    console.log('Deployed facet:', facetName, ' with address:', facet.address);
});
(0, config_1.task)("owner", "Get the owner of the diamond")
    .addParam("diamond", "Address of the Diamond to upgrade")
    .setAction(async (taskArgs, hre) => {
    const diamondAddress = taskArgs.diamond;
    const ownershipFacet = await hre.ethers.getContractAt("OwnershipFacet", diamondAddress);
    const owner = await ownershipFacet.owner();
    console.log(owner);
});
//# sourceMappingURL=logon.js.map