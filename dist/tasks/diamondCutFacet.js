"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deployDiamondCore = exports.deployAllGameFacets = exports.deployFacets = void 0;
const config_1 = require("hardhat/config");
const utils_1 = require("../lib/utils");
// ----------------------------------------
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
    let facet = await deployFacets(hre, diamondAddress, [facetName], signer);
    return facet;
});
async function deployFacets(hre, diamondAddress, facetNames, signer) {
    let cut = [];
    for (let i = 0; i < facetNames.length; i++) {
        let facetName = facetNames[i];
        let facet = await (0, utils_1.deployContract)(hre, facetName, signer);
        console.log('Deploy facet:', facetName, ' with address:', facet.address);
        cut.push({
            facetAddress: facet.address,
            facetName: facetName,
            functionSignatures: (0, utils_1.getFunctionSignatures)(facet)
        });
    }
    const diamondCut = await hre.ethers.getContractAt('IDiamondCut', diamondAddress, signer);
    // call to init function
    let tx = await diamondCut.diamondCut(cut, hre.ethers.constants.AddressZero, "0x"); // , { gasLimit: 30000000}
    let receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }
    console.log('Diamond upgrade successful. Cuts:', cut);
}
exports.deployFacets = deployFacets;
// ----------------------------------------
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
// --------------------------------------------------------------------------------------------
(0, config_1.task)("deployAllGameFacets", "Deploy all facets")
    .addParam("diamond", "The diamond address")
    .addFlag("useledger", "Set to true if Ledger should be used for signing")
    .setAction(async (taskArgs, hre) => {
    //Instantiate the Signer
    let signer = await (0, utils_1.getSigner)(hre, taskArgs.diamond, taskArgs.useledger);
    await deployAllGameFacets(hre, taskArgs.diamond, signer);
});
async function deployAllGameFacets(hre, diamondAddress, signer) {
    const names = await hre.artifacts.getAllFullyQualifiedNames();
    const facetNames = names.map((v) => {
        const arr = v.split(':');
        const path = arr[0];
        const name = arr[1];
        if (!path.startsWith('contracts/game/') || !name.endsWith('Facet'))
            return '';
        return name;
    }).filter((v) => v.length > 0);
    await deployFacets(hre, diamondAddress, facetNames, signer);
}
exports.deployAllGameFacets = deployAllGameFacets;
// --------------------------------------------------------------------------------------------
(0, config_1.task)("deployDiamondCore", "Deploy core diamond")
    .addFlag("useledger", "Set to true if Ledger should be used for signing")
    .setAction(async (taskArgs, hre) => {
    //Instantiate the Signer
    let signer = await (0, utils_1.getSigner)(hre, undefined, taskArgs.useledger);
    return await deployDiamondCore(hre, signer);
});
async function deployDiamondCore(hre, signer) {
    let diamondCutFacet = await (0, utils_1.deployContract)(hre, 'DiamondCutFacet', signer);
    // deploy Diamond
    const owner = await signer.getAddress();
    let diamond = await (0, utils_1.deployContract)('Diamond', owner, diamondCutFacet.address);
    //console.log('Diamond deployed to:', diamond.address);
    return diamond.address;
}
exports.deployDiamondCore = deployDiamondCore;
// --------------------------------------------------------------------------------------------
//# sourceMappingURL=diamondCutFacet.js.map