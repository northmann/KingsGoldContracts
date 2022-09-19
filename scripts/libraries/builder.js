const { ethers } = require("hardhat");

const { getFunctionSignatures, getSelectors, FacetCutAction } = require('./diamond.js')
const { createBeacon, createUpgradeable, deployContract, getContractInstance, getId, writeSetting, createConfigFile } = require("./Auxiliary.js");
const { BigNumber } = require("ethers");
const { getAppSettings } = require('../../dist/appSettings.js');
const { parseEther } = require("ethers/lib/utils.js");

let cut = [];
let diamondCutFacet;
let diamond;
let diamondInit;
let provinceNFT;
let gold;

const eth0 = BigNumber.from(0);
const eth1 = ethers.utils.parseUnits("1.0", "ether");
const bigNumber50eth = ethers.utils.parseUnits("50.0", "ether"); // 100 mill eth
const bigNumber100eth = ethers.utils.parseUnits("100.0", "ether"); // 100 mill eth
const bigNumber200eth = ethers.utils.parseUnits("200.0", "ether"); // 100 mill eth
const bigNumber100Mill = ethers.utils.parseUnits("100000000.0", "ether"); // 100 mill eth
const ethZero = ethers.utils.parseEther('0');


async function deployKingsGold(user, diamond) {
    if (!user) throw "Missing user instance";

    gold = await deployContract("KingsGold", diamond.address);
    writeSetting("KingsGold", gold.address);

    return gold;
}

async function deployProvinceNFT(owner, diamond) {
    if(!diamond) throw "Missing diamond instance";

    provinceNFT = await createUpgradeable("ProvinceNFT", [diamond.address]);

    return provinceNFT;
}

async function deployCommodities(user, diamond) {
    if (!user) throw "Missing user instance";

    food = await createUpgradeable("Food", [diamond.address]);

    wood = await createUpgradeable("Wood", [diamond.address]);

    rock = await createUpgradeable("Rock", [diamond.address]);

    iron = await createUpgradeable("Iron", [diamond.address]);

    return { food, wood, rock, iron };
}


async function mintCommodities(user) {
    await food.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
    await wood.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
    await rock.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
    await iron.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
}

async function fundUserWithGold(user) {
    let balance = await gold.balanceOf(user.address);
    if (balance.eq(eth0)) {
        let treasuryFacet = await ethers.getContractAt('TreasuryFacet', diamond.address, user);

        let tx = await treasuryFacet.buy({value: bigNumber200eth });
        await tx.wait();

        // Approve the diamond contract to spend the gold
        let userGoldInstance = await ethers.getContractAt('KingsGold', gold.address, user);
        let approveTx = await userGoldInstance.approve(diamond.address, bigNumber200eth);
        await approveTx.wait();

    }
}


async function deployDiamonBasics(ownerAddress) {
    // deploy DiamondCutFacet
    diamondCutFacet = await deployContract('DiamondCutFacet');
    // deploy Diamond
    diamond = await deployContract('Diamond', ownerAddress, diamondCutFacet.address);
    writeSetting("Diamond", diamond.address);

    // deploy DiamondInit
    diamondInit = await deployContract('DiamondInit');
    //writeSetting("DiamondInit", diamondInit.address); 

    return { diamond, diamondCutFacet, diamondInit };
}



async function deployFacets(owner, diamond) {
    // deploy facets
    console.log('')
    console.log('Deploying facets')
    const FacetNames = [
        'OwnershipFacet',
        'AccessControlFacet',
        'ConfigurationFacet',
        'DiamondLoupeFacet',
        'MultiCallFacet',
        'ProvinceFacet',
        'TreasuryFacet',
        'UserFacet',
        'StructureEventFacet'

    ]
    
    for (const FacetName of FacetNames) {

        const facet = await deployContract(FacetName);
        console.log('Deploying facet:', FacetName, ' with address:', facet.address);

        cut.push({
            facetAddress: facet.address,
            facetName: FacetName,
            functionSignatures: getFunctionSignatures(facet)
        })
    }

}


// upgrade diamond with facets
async function upgradeDiamond(owner, diamond, initArgs) {
    // upgrade diamond with facets
    console.log('')
    console.log('Diamond Cut:', cut)
    const diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address)
    let tx
    let receipt
    // call to init function
    let functionCall = diamondInit.interface.encodeFunctionData('init', [initArgs])
    tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
    console.log('Diamond cut tx: ', tx.hash)
    receipt = await tx.wait()
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    console.log('Completed diamond cut')
    return diamond.address
}



async function deploySingels(owner, diamond) {
    let r = {};
    r.provinceNFT = await deployProvinceNFT(owner, diamond);
    r.gold = await deployKingsGold(owner, diamond);
    let commodities = await deployCommodities(owner, diamond);
    r = { ...r, ...commodities };
   
    return r;
}

async function createContractConfigFile(path) {
        await createConfigFile(path);
    }
    
async function initPlayer(owner, diamond, targetAddress) {
 
    let tx = await owner.sendTransaction({
      to: targetAddress,
      value: ethers.utils.parseEther("100") // 100 ether
    });
  
    await tx.wait();
    console.log("Test account9 address funded");

    let configurationFacet = await ethers.getContractAt('ConfigurationFacet', diamond.address, owner);
    tx = await configurationFacet.mintGold(targetAddress, bigNumber100eth);
    await tx.wait();

    tx = await configurationFacet.approveGold(targetAddress, bigNumber100eth);
    await tx.wait();
    
    // tx = await configurationFacet.mintCommodities(targetAddress, parseEther("10"), bigNumber100eth, 0,0);
    // await tx.wait();



   
    let provinceFacet = await ethers.getContractAt('ProvinceFacet', diamond.address, owner);
    tx = await provinceFacet.createProvinceAtTarget("Dragonville", targetAddress);
    await tx.wait();

    console.log("Province minted for Test account9");

    tx = await configurationFacet.approveCommodities(targetAddress, bigNumber100Mill, bigNumber100Mill, bigNumber100Mill, bigNumber100Mill);
    await tx.wait();
    console.log("Approve Commodities for Test account9");

}


async function transferOwnership(owner, targetAddress, diamond) {
    let ownershipFacet = await ethers.getContractAt('OwnershipFacet', diamond.address, owner);
    let tx = await ownershipFacet.transferOwnership(targetAddress);
    await tx.wait();
    console.log("Ownership transferred to: ", targetAddress);
}

function initArgs(ownerAdress) {
    let r = {
        owner: ownerAdress
    };

    return r;
}

module.exports = {
    transferOwnership,
    initArgs,
    deployDiamonBasics,
    deployFacets,
    upgradeDiamond,
    deployKingsGold,
    deployCommodities,
    deployProvinceNFT,
//    mintCommodities,
    deploySingels,
    fundUserWithGold,
    createContractConfigFile,
    initPlayer,
    eth1,
    bigNumber100eth
};
