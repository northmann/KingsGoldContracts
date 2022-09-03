const { ethers } = require("hardhat");
const { BigNumber, utils } = require("ethers");
const { getAssetData, getAssetActionData } = require("../../dist/Assets.js");


const eth0 = BigNumber.from(0);
const eth1 = ethers.utils.parseUnits("1.0", "ether");
const bigNumber50eth = ethers.utils.parseUnits("50.0", "ether"); // 100 mill eth
const bigNumber100eth = ethers.utils.parseUnits("100.0", "ether"); // 100 mill eth
const bigNumber100Mill = ethers.utils.parseUnits("100000000.0", "ether"); // 100 mill eth

let contract;



async function initAppStoreAssets(owner, diamondAddress) {
  let contract = await ethers.getContractAt('ConfigurationFacet', diamondAddress, owner);

  let assets = getAssetData();
  //let asset = assets[0];
  //console.log(asset);

  let tx = await contract.setAppStoreAssets(assets);
  await tx.wait();
  console.log("Assets initialized");
}

async function initAppStoreAssetAction(owner, diamondAddress) {
  let contract = await ethers.getContractAt('ConfigurationFacet', diamondAddress, owner);

  let arr = getAssetActionData();

  let tx = await contract.setAppStoreAssetActions(arr);
  await tx.wait();

  console.log("AssetActions initialized");
}

async function deployData(owner, diamondAddress) {
  await initAppStoreAssets(owner, diamondAddress);
  await initAppStoreAssetAction(owner, diamondAddress);

  console.log("Data initialized");
  let userContract = await ethers.getContractAt('UserFacet', diamondAddress, owner);
  const tx = await userContract.setKingdom();
  await tx.wait();
  console.log("Kingdom initialized");
}


async function testRoles(owner, diamondAddress) {
  let ac = await ethers.getContractAt('AccessControlFacet', diamondAddress, owner);

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