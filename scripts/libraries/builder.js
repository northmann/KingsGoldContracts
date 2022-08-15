const { ethers } = require("hardhat");

const { getSelectors, FacetCutAction } = require('./diamond.js')
const { createBeacon, createUpgradeable, deployContract, getContractInstance, getId, writeSetting } = require("./Auxiliary.js");

let cut = [];
let diamondCutFacet;
let diamond;
let diamondInit;

async function addKingsGold(user, game) {
    if (!user) throw "Missing user instance";

    gold = await deployContract("KingsGold", game.address);

    return gold;
}

async function addCommodities(user, game) {
    if (!user) throw "Missing user instance";

    food = await createUpgradeable("Food", [game.address]);

    wood = await createUpgradeable("Wood", [game.address]);

    rock = await createUpgradeable("Rock", [game.address]);

    iron = await createUpgradeable("Iron", [game.address]);

    return { food, wood, rock, iron };
}

// async function mintCommodities(user) {
//     await food.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
//     await wood.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
//     await rock.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
//     await iron.mint(user.address, bigNumber100eth);        // Give me a lot of new coins
// }

async function deployDiamonBasics(owner) {
    // deploy DiamondCutFacet
    diamondCutFacet = await deployContract('DiamondCutFacet');
    // deploy Diamond
    diamond = await deployContract('Diamond', owner.address, diamondCutFacet.address);
    // deploy DiamondInit
    diamondInit = await deployContract('DiamondInit');

    return diamond;
}



async function deployFacets(owner, game) {
    // deploy facets
    console.log('')
    console.log('Deploying facets')
    const FacetNames = [
        'DiamondLoupeFacet',
        'OwnershipFacet'
    ]
    
    for (const FacetName of FacetNames) {
        console.log('Deploying facet:', FacetName);

        const Facet = await ethers.getContractFactory(FacetName)
        const facet = await Facet.deploy()
        await facet.deployed()

        console.log(`${FacetName} deployed: ${facet.address}`)
        cut.push({
            facetAddress: facet.address,
            action: FacetCutAction.Add,
            functionSelectors: getSelectors(facet)
        })
    }
}


// upgrade diamond with facets
async function upgradeDiamond(owner, game) {
    // upgrade diamond with facets
    console.log('')
    console.log('Diamond Cut:', cut)
    const diamondCut = await ethers.getContractAt('IDiamondCut', game.address)
    let tx
    let receipt
    // call to init function
    let functionCall = diamondInit.interface.encodeFunctionData('init')
    tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
    console.log('Diamond cut tx: ', tx.hash)
    receipt = await tx.wait()
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    console.log('Completed diamond cut')
    return diamond.address
}



async function deploySingels(owner, game) {
    await addKingsGold(owner, game);
    await addCommodities(owner, game);
}

module.exports = {
    deployDiamonBasics,
    deployFacets,
    upgradeDiamond,
    addKingsGold,
    addCommodities,
//    mintCommodities,
    deploySingels
};
