/* global ethers */
/* eslint prefer-const: "off" */
const { ethers } = require("hardhat");

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
const { getId, deployContract, createUpgradeable, createConfigFile } = require('./libraries/auxiliary.js');
const { deploySingels, deployDiamonBasics, deployFacets, upgradeDiamond, initArgs } = require("./libraries/builder.js");


async function deployDiamond () {
  const accounts = await ethers.getSigners()
  const owner = accounts[0]
  const user = accounts[1]

  const { diamond, diamondCutFacet, diamondInit } = await deployDiamonBasics(owner);

  let singles = await deploySingels(owner, diamond);
  
  await deployFacets(owner, diamond);

  initializeData = await initArgs(singles);
  
  console.log("Init:", initializeData);
  //let functionCall = diamondInit.interface.encodeFunctionData('init', [initializeData])
 
  await upgradeDiamond(owner, diamond, initializeData);

  return { diamond, diamondCutFacet, diamondInit, ...singles, initializeData, owner, user };
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDiamond = deployDiamond
