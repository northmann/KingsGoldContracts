"use strict";
//import { parseUnits, BigNumber } from 'ethers';
Object.defineProperty(exports, "__esModule", { value: true });
exports.deployContract = exports.getFunctionSignatures = exports.getSigner = exports.setBalance = void 0;
//import { Signer } from "@ethersproject/abstract-signer";
const ethers_ledger_1 = require("@northmann/ethers-ledger");
const utils_1 = require("ethers/lib/utils");
async function setBalance(hre, signer, amount) {
    await hre.network.provider.request({
        method: "hardhat_setBalance",
        params: [signer, amount.toHexString()],
    });
}
exports.setBalance = setBalance;
async function getSigner(hre, diamondAddress, useledger) {
    //Instantiate the Signer
    let signer;
    const testing = ["hardhat", "localhost"].includes(hre.network.name);
    console.log("network is testing: ", testing);
    console.log("Using Ledger: ", useledger);
    if (useledger) {
        // m / purpose' / coin_type' / account' / change / address_index
        // m/44'/60'/0'/0/0
        // Metamask uses m/44'/60'/(account)'/0/(address index)
        //signer = new LedgerSigner(hre.ethers.provider, "hid", "m/44'/60'/100'/0/0");
        signer = new ethers_ledger_1.LedgerSigner(hre.ethers.provider, "m/44'/60'/100'/0/0");
        if (testing) {
            console.log("signer address: ", await signer.getAddress());
            const owner = await signer.getAddress();
            console.log("adding balance to owner: ", owner);
            const value = (0, utils_1.parseUnits)("0x100000000000000000000000", 1); // 100
            setBalance(hre, owner, value);
            // await hre.network.provider.request({
            //   method: "hardhat_setBalance",
            //   params: [owner, "0x100000000000000000000000"],
            // });
            // const feeData = await hre.ethers.provider.getFeeData();
            // //const feeDataInEth = hre.ethers.utils.formatEther(feeData);
            // console.log(`feeData: `, feeData);
            let balance = await hre.ethers.provider.getBalance(owner);
            // convert a currency unit from wei to ether
            const balanceInEth = hre.ethers.utils.formatEther(balance);
            console.log(`balance: ${balanceInEth} ETH`);
        }
        //signer = new LedgerSigner(hre.ethers.provider, `m/44'/60'/0'/0/0`);
        //signer = new LedgerSigner(hre.ethers.provider, "m/44'/60'/100'/0/0");
        //signer = new LedgerSigner();
        console.log("Ledger Signer: ", await signer.getAddress());
        //console.log("Ledger Signer: ", await signer.getBalance());
        return signer;
    }
    if (diamondAddress) {
        console.log("loading owner from diamondAddress: ", diamondAddress);
        const ownershipFacet = await hre.ethers.getContractAt("OwnershipFacet", diamondAddress);
        const owner = await ownershipFacet.owner();
        if (owner && owner != "0x0000000000000000000000000000000000000000") {
            await hre.network.provider.request({
                method: "hardhat_impersonateAccount",
                params: [owner],
            });
            await hre.network.provider.request({
                method: "hardhat_setBalance",
                params: [owner, "0x100000000000000000000000"],
            });
            signer = await hre.ethers.getSigner(owner);
            console.log("Owner ImpersonateAccount Signer: ", await signer.getAddress());
            return signer;
        }
    }
    signer = await hre.ethers.getSigner();
    console.log("Default hardhat Signer: ", await signer.getAddress());
    return signer;
}
exports.getSigner = getSigner;
function getFunctionSignatures(contract) {
    const signatures = Object.keys(contract.interface.functions);
    const names = signatures.reduce((acc, val) => {
        if (val !== 'init(bytes)') {
            acc.push(val);
        }
        return acc;
    }, []);
    return names;
}
exports.getFunctionSignatures = getFunctionSignatures;
async function deployContract(hre, contractName, signer, ...args) {
    const Contract = await hre.ethers.getContractFactory(contractName, signer);
    const instance = await Contract.deploy(...args);
    console.log(`${contractName} contract deployed to ${instance.address}`);
    return instance;
}
exports.deployContract = deployContract;
//# sourceMappingURL=utils.js.map