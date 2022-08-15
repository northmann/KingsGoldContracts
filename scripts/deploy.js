/* global ethers */
/* eslint prefer-const: "off" */
const { ethers } = require("hardhat");

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
const { getId, deployContract, createUpgradeable, createConfigFile } = require('./libraries/auxiliary.js');
const { deploySingels, deployDiamonBasics, deployFacets, upgradeDiamond } = require("./libraries/builder.js");


async function deployDiamond () {
  const accounts = await ethers.getSigners()
  const owner = accounts[0]

  const game = await deployDiamonBasics(owner);

  await deploySingels(owner, game);
  await deployFacets(owner, game);
  await upgradeDiamond(owner, game);
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
