const { ethers } = require("hardhat");

const { getSelectors, FacetCutAction } = require('./diamond.js')
const { createBeacon, createUpgradeable, deployContract, getContractInstance, getId, writeSetting, createConfigFile } = require("./Auxiliary.js");
const { BigNumber } = require("ethers");

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

        let tx = await treasuryFacet.buy({value: bigNumber100eth });
        await tx.wait();

        // Approve the diamond contract to spend the gold
        let userGoldInstance = await ethers.getContractAt('KingsGold', gold.address, user);
        let approveTx = await userGoldInstance.approve(diamond.address, bigNumber100eth);
        await approveTx.wait();

    }
}


async function deployDiamonBasics(owner) {
    // deploy DiamondCutFacet
    diamondCutFacet = await deployContract('DiamondCutFacet');
    // deploy Diamond
    diamond = await deployContract('Diamond', owner.address, diamondCutFacet.address);
    writeSetting("Diamond", diamond.address);

    // deploy DiamondInit
    diamondInit = await deployContract('DiamondInit');

    return { diamond, diamondCutFacet, diamondInit };
}



async function deployFacets(owner, diamond) {
    // deploy facets
    console.log('')
    console.log('Deploying facets')
    const FacetNames = [
        'AccessControlFacet',
        'ConfigurationFacet',
        'DiamondLoupeFacet',
        'MultiCallFacet',
        'ProvinceFacet',
        'TreasuryFacet',
        'UserFacet'

    ]
    
    for (const FacetName of FacetNames) {

        const facet = await deployContract(FacetName);
        console.log('Deploying facet:', FacetName, ' with address:', facet.address);

        cut.push({
            facetAddress: facet.address,
            action: FacetCutAction.Add,
            functionSelectors: getSelectors(facet)
        })
    }

    checkSelectors();
}

async function checkSelectors() {
    for (const facet of cut) {
        for (const functionSelector of facet.functionSelectors) {

            for(const innerFacet of cut) {
                for (const innerFunctionSelector of innerFacet.functionSelectors) {
                    if(innerFacet.facetAddress == facet.facetAddress) break;

                    if (innerFunctionSelector === functionSelector) {

                        throw Error(`Duplicate function selector: ${functionSelector} in facet: ${facet.facetAddress} and in facet: ${innerFacet.facetAddress}`);
                    }
                }
            }
        }
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
    
    tx = await configurationFacet.mintCommodities(targetAddress, 0, bigNumber100eth, 0,0);
    await tx.wait();

    tx = await configurationFacet.approveCommodities(targetAddress, bigNumber100eth);
    await tx.wait();

    console.log("Gold and resource minted for Test account9");

   
    let provinceFacet = await ethers.getContractAt('ProvinceFacet', diamond.address, owner);
    tx = await provinceFacet.mintProvince("Dragonville", targetAddress);
    await tx.wait();

    console.log("Province minted for Test account9");
}


async function initArgs(singles) {
    let r = {};
    r.provinceNFT = singles.provinceNFT.address;
    r.gold = singles.gold.address;
    r.food = singles.food.address;
    r.wood = singles.wood.address;
    r.rock = singles.rock.address;
    r.iron = singles.iron.address;

    r.provinceLimit = ethZero;
    r.baseProvinceCost = ethZero;
    r.baseCommodityReward = ethZero;
    r.baseGoldCost = ethZero;
    r.baseUnit = ethZero;
    r.timeBaseCost = ethZero;
    r.goldForTimeBaseCost = ethZero;
    r.foodBaseCost = ethZero;
    r.woodBaseCost = ethZero;
    r.rockBaseCost = ethZero;
    r.ironBaseCost = ethZero;
    r.vassalTribute = ethZero; 

    return r;
}

module.exports = {
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
