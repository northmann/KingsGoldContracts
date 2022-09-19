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
(0, config_1.task)("functionSignatures", "Prints function signatures")
    .addParam("name", "The contract's name")
    .setAction(async (taskArgs, hre) => {
    const contract = await hre.ethers.getContractFactory(taskArgs.name);
    const signatures = Object.keys(contract.interface.functions);
    signatures.forEach((v, i, a) => {
        let sig = contract.interface.getSighash(v);
        console.log(v, ' : ', sig);
    });
});
(0, config_1.task)("facets", "Prints all facets")
    //  .addParam("name", "The contract's name")
    .setAction(async (taskArgs, hre) => {
    const names = await hre.artifacts.getAllFullyQualifiedNames();
    names.forEach((v, i) => {
        const arr = v.split(':');
        const path = arr[0];
        const name = arr[1];
        if (!path.startsWith('contracts/game/') || !name.endsWith('Facet'))
            return;
        console.log(name);
    });
});
(0, config_1.task)("deployAllFacets", "Deploy all facets")
    .addParam("diamond", "The diamond address")
    .addFlag("useledger", "Set to true if Ledger should be used for signing")
    .setAction(async (taskArgs, hre) => {
    const names = await hre.artifacts.getAllFullyQualifiedNames();
    for (const v of names) {
        const arr = v.split(':');
        const path = arr[0];
        const name = arr[1];
        if (!path.startsWith('contracts/game/') || !name.endsWith('Facet'))
            continue;
        const arg = {
            diamond: taskArgs.diamond,
            facet: name,
            useledger: taskArgs.useledger
        };
        await hre.run("deployFacet", arg);
    }
    ;
});
//# sourceMappingURL=diamondCutFacet.js.map