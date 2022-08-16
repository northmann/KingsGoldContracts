const { ethers } = require("hardhat");

const { getSelectors, FacetCutAction } = require('./diamond.js')
const { createBeacon, createUpgradeable, deployContract, getContractInstance, getId, writeSetting } = require("./Auxiliary.js");

let cut = [];
let diamondCutFacet;
let diamond;
let diamondInit;
let provinceNFT;

async function deployKingsGold(user, game) {
    if (!user) throw "Missing user instance";

    gold = await deployContract("KingsGold", game.address);

    return gold;
}

async function deployProvinceNFT(owner, game) {
    if(!game) throw "Missing game instance";

    provinceNFT = await createUpgradeable("ProvinceNFT", [game.address]);

    return provinceNFT;
}

async function deployCommodities(user, game) {
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

    return { diamond, diamondCutFacet, diamondInit };
}



async function deployFacets(owner, game) {
    // deploy facets
    console.log('')
    console.log('Deploying facets')
    const FacetNames = [
        'DiamondLoupeFacet',
        'AccessControlFacet',
        'MultiCallFacet',
        'ProvinceFacet',
        'TreasuryFacet',
        'UserFacet'

    ]
    
    for (const FacetName of FacetNames) {
        console.log('Deploying facet:', FacetName);

        const facet = await deployContract(FacetName);

        cut.push({
            facetAddress: facet.address,
            action: FacetCutAction.Add,
            functionSelectors: getSelectors(facet)
        })
    }
}


// upgrade diamond with facets
async function upgradeDiamond(owner, game, initArgs) {
    // upgrade diamond with facets
    console.log('')
    console.log('Diamond Cut:', cut)
    const diamondCut = await ethers.getContractAt('IDiamondCut', game.address)
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



async function deploySingels(owner, game) {
    let r = {};
    r.provinceNFT = await deployProvinceNFT(owner, game);
    r.gold = await deployKingsGold(owner, game);
    let commodities = await deployCommodities(owner, game);
    r = { ...r, ...commodities };
   
    return r;
}



async function initArgs(singles) {
    let r = {};
    r.provinceNFT = singles.provinceNFT.address;
    r.gold = singles.gold.address;
    r.food = singles.food.address;
    r.wood = singles.wood.address;
    r.rock = singles.rock.address;
    r.iron = singles.iron.address;

    r.provinceLimit = 10;
    r.baseProvinceCost = ethers.utils.parseEther('1');
    r.baseCommodityReward = ethers.utils.parseEther('100');

    // r.getArrayArgs = function (arr) { 
    //     let x = [];
    //     x.push(initArgs.provinceNFT);
    //     x.push(initArgs.gold);
    //     x.push(initArgs.food);
    //     x.push(initArgs.wood);
    //     x.push(initArgs.rock);
    //     x.push(initArgs.iron);

    //     x.push(initArgs.provinceLimit);
    //     x.push(initArgs.baseProvinceCost);
    //     x.push(initArgs.baseCommodityReward);

    //     return x;
    // }

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
    deploySingels
};
