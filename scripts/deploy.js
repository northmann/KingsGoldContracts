/* global ethers */
/* eslint prefer-const: "off" */
const { ethers } = require("hardhat");

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
const { deploySingels, deployDiamonBasics, deployFacets, upgradeDiamond, initArgs, createContractConfigFile, initPlayer } = require("./libraries/builder.js");
const { deployData } = require("./libraries/configuration.js");



async function deployDiamond () {
  const accounts = await ethers.getSigners()
  const owner = accounts[0]
  const user = accounts[1]
  const user2 = accounts[2]

  const { diamond, diamondCutFacet, diamondInit } = await deployDiamonBasics(owner);

  let singles = await deploySingels(owner, diamond);

  // Write the config file
  //let filePath =__dirname+"\\..\\frontend\\src\\abi\\"; 
  let filePath = "./frontend/src/abi/ContractAddresses.json";
  await createContractConfigFile(filePath);

  
  await deployFacets(owner, diamond);

  initializeData = await initArgs(singles);
  
  console.log("Init:", initializeData);
  //let functionCall = diamondInit.interface.encodeFunctionData('init', [initializeData])
 
  await upgradeDiamond(owner, diamond, initializeData);


  //await testRoles(owner, diamond);
  await deployData(owner, diamond);

  await initPlayer(owner, diamond, "0xF046bCa0D18dA64f65Ff2268a84f2F5B87683C47");

  console.log("Deploy done");

  // const metaMaskAddr = "0xEeB996A982DE087835e3bBead662f64BE228F531";
  // tx = await owner.sendTransaction({
  //     to: metaMaskAddr,
  //     value: ethers.utils.parseEther("100") // 100 ether
  //   });

  // await tx.wait();
  // console.log("Test metamask address funded: ", metaMaskAddr);

  // const account9 = "0xF046bCa0D18dA64f65Ff2268a84f2F5B87683C47";
  // tx = await owner.sendTransaction({
  //   to: account9,
  //   value: ethers.utils.parseEther("100") // 100 ether
  // });

  // await tx.wait();
  // console.log("Test account9 address funded: ", metaMaskAddr);




  return { diamond, diamondCutFacet, diamondInit, ...singles, initializeData, owner, user, user2 };
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

exports.deployDiamond = deployDiamond;
