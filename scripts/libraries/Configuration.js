const { ethers } = require("hardhat");
const { BigNumber, utils } = require("ethers");
const { getAssetData, getAssetActionData } = require("../data/Assets.js");


const eth0 = BigNumber.from(0);
const eth1 = ethers.utils.parseUnits("1.0", "ether");
const bigNumber50eth = ethers.utils.parseUnits("50.0", "ether"); // 100 mill eth
const bigNumber100eth = ethers.utils.parseUnits("100.0", "ether"); // 100 mill eth
const bigNumber100Mill = ethers.utils.parseUnits("100000000.0", "ether"); // 100 mill eth

let contract;



async function initAppStoreAssets(owner, diamond) {
    contract = contract || await ethers.getContractAt('ConfigurationFacet', diamond.address, owner);

    let assets = getAssetData();
    //let asset = assets[0];
    //console.log(asset);

    let tx = await contract.setAppStoreAssets(assets);
    await tx.wait();
    console.log("Assets initialized");
}

async function initAppStoreAssetAction(owner, diamond) {
  contract = contract || await ethers.getContractAt('ConfigurationFacet', diamond.address, owner);

  let assetActions = getAssetActionData();

  // let assetActionArg = assetActionArgs[0];
  //console.log(assetActions);
  //await contract.setAppStoreAssetAction(assetActionArg.typeId, assetActionArg.actionId, assetActionArg.item);

  let tx = await contract.setAppStoreAssetActions(assetActions);
  await tx.wait();
  console.log("AssetActions initialized");
}

async function deployData(owner, diamond) {
  await initAppStoreAssets(owner, diamond);
  await initAppStoreAssetAction(owner, diamond);
}


async function testRoles(owner, diamond) {
  let ac = await ethers.getContractAt('AccessControlFacet', diamond.address, owner);

  const CONFIG_ROLE = utils.keccak256(utils.toUtf8Bytes("CONFIG_ROLE"));
  //const DEFAULT_ADMIN_ROLE = utils.keccak256(utils.toUtf8Bytes("CONFIG_ROLE"));

  console.log("Owner has role of CONFIG_ROLE: ", await ac.hasRole(CONFIG_ROLE, owner.address));

}





module.exports = {
  initAppStoreAssets,
  initAppStoreAssetAction,
  testRoles,
  deployData
};