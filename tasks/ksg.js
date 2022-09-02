//const { ethers } = require("hardhat");
const { getAssetActionData, getAssetData } = require("../scripts/data/Assets");

task("user", "Prints an user json data")
  .addParam("contract", "The contract's address")
  .addParam("account", "The account's address")
  .setAction(async (taskArgs) => {
    const contract = await ethers.getContractAt('UserFacet', taskArgs.contract);
    const user = await contract.getUser(taskArgs.account);
    console.log(user);
  });




task("getProvince", "Prints getProvince json data")
  .addParam("contract", "The contract's address")
  .addOptionalParam("id", "The Province ID number", 0, types.int)
  .setAction(async (taskArgs) => {

    const contract = await ethers.getContractAt('ProvinceFacet', taskArgs.contract);
    const data = await contract.getProvince(taskArgs.id);
    console.log(data);
  });

task("getProvinceStructures", "Prints getProvinceStructures json data")
  .addParam("contract", "The contract's address")
  .addOptionalParam("id", "The Province ID number", 0, types.int)
  .setAction(async (taskArgs) => {

    const contract = await ethers.getContractAt('ProvinceFacet', taskArgs.contract);
    const data = await contract.getProvinceStructures(taskArgs.id);
    console.log(data);
  });

  // --------------------------------------------------------------
  // ConfigurationFacet
  // --------------------------------------------------------------

  task("assets", "Prints assets json data")
  .addParam("contract", "The contract's address")
  .addParam("assetTypeId", "The Asset Type ID number", 0, types.int)
  .setAction(async (taskArgs) => {

    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);
    const assets = await contract.getAsset(taskArgs.assetTypeId);
    console.log(assets);
  });


task("getAssetAction", "Prints AssetAction json data")
  .addParam("contract", "The contract's address")
  .addParam("assetTypeId", "The Asset Type ID number", 0, types.int)
  .addParam("eventActionId", "The Event Type ID number", 0, types.int)
  .setAction(async (taskArgs) => {

    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);
    const assets = await contract.getAssetAction(taskArgs.assetTypeId, taskArgs.eventActionId);
    console.log(assets);
  });


  task("setAppStoreAssetActions", "Deploys the AssetActions")
  .addParam("contract", "The contract's address")
  .setAction(async (taskArgs) => {
    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);
    
    const arr = getAssetActionData();
    //console.log(arr);

    console.log("Deploying AssetActions...");
    let tx = await contract.setAppStoreAssetActions(arr);
    await tx.wait();
    console.log("Deployed", arr.length,"AssetActions");
  });


  task("setAppStoreAssets", "Deploys the Assets")
  .addParam("contract", "The contract's address")
  .setAction(async (taskArgs) => {
    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);
    
    let assets = getAssetData();
    //console.log(assets);
    console.log("Deploying Assets...");
    let tx = await contract.setAppStoreAssets(assets);
    await tx.wait();
    console.log("Deployed", assets.length, "Assets");
  });
