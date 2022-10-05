//const { ethers } = require("hardhat");
const { BigNumber, library } = require("ethers");
const { parseEther } = require("ethers/lib/utils.js");
const { getAppSettings, getContracts } = require("../dist/index.js");
//const { getContracts } = require("../dist/contracts.js");
const { getAssetActionData, getAssetData } = require("../dist/Assets.js");


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

  task("getProvinceActiveStructureTasks", "Prints getProvinceStructures json data")
  .addParam("diamond", "The diamond's address")
  .addOptionalParam("id", "The Province ID number", 0, types.int)
  .setAction(async (taskArgs) => {

    const contract = await ethers.getContractAt('ProvinceFacet', taskArgs.diamond);
    const data = await contract.getProvinceActiveStructureTasks(taskArgs.id);
    console.log(data);
  });
// --------------------------------------------------------------
// ConfigurationFacet
// --------------------------------------------------------------


// View ----------------------------------------------------

task("getBaseSettings", "Prints the baseSettings")
  .addParam("diamond", "The contract's address")
  .setAction(async (taskArgs) => {

    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.diamond);
    const settings = await contract.getBaseSettings();
    console.log(settings);
  });


task("getAsset", "Prints assets json data")
  .addParam("diamond", "The contract's address")
  .addParam("assetTypeId", "The Asset Type ID number", 0, types.int)
  .setAction(async (taskArgs) => {

    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.diamond);
    const asset = await contract.getAsset(taskArgs.assetTypeId);
    console.log(asset);
  });

task("getAssets", "Prints assets json data")
  .addParam("contract", "The contract's address")
  .setAction(async (taskArgs) => {

    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);
    const assets = await contract.getAssets();
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
  .addParam("diamond", "The diamond's address")
  .setAction(async (taskArgs) => {
    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.diamond);

    const arr = getAssetActionData();

    console.log("Deploying AssetActions...");
    let tx = await contract.setAppStoreAssetActions(arr);
    await tx.wait();
    console.log("Deployed", arr.length, "AssetActions");
  });

// Public ----------------------------------------------------

task("setBaseSettings", "Deploys the initialisation data")
  .addParam("contract", "The contract's address")
  .addParam("chainId", "The chain id number", 1337, types.int)
  .setAction(async (taskArgs) => {
    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);

    let initArgs = getAppSettings(taskArgs.chainId);

    console.log("Deploying BaseSettings...");
    let tx = await contract.setBaseSettings(initArgs);
    await tx.wait();
    console.log("Deployed");
  });


task("setAppStoreAssets", "Deploys the Assets")
  .addParam("diamond", "The diamond's address")
  .setAction(async (taskArgs) => {
    const contract = await ethers.getContractAt('ConfigurationFacet', taskArgs.diamond);

    let assets = getAssetData();

    console.log("Deploying Assets...");
    let tx = await contract.setAppStoreAssets(assets);
    await tx.wait();
    console.log("Deployed", assets.length, "Assets");
  });

  task("mintGold", "fundUserWithGold")
  .addParam("contract", "The contract's address")
  .addParam("user", "The user's address")
  .addParam("amount", "The gold amount in ethers", 100, types.int)
  .setAction(async (taskArgs) => {
    let amount = parseEther(taskArgs.amount.toString(), 18);

    let configurationFacet = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);
    console.log("Minting gold...");
    tx = await configurationFacet.mintGold(taskArgs.user, amount);
    await tx.wait();
    console.log("Minted");
  });

  task("approveGold", "Approve sending of user's gold")
  .addParam("contract", "The contract's address")
  .addParam("user", "The user's address")
  .addParam("amount", "The gold amount in ethers", 10000000, types.int)
  .setAction(async (taskArgs) => {
    let amount = parseEther(taskArgs.amount.toString(), 18);

    let configurationFacet = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);
    console.log("Approving gold...");
    tx = await configurationFacet.approveGold(taskArgs.user, amount);
    await tx.wait();
    console.log("Approved");
  });


  task("mintCommodities", "fundUserWithGold")
  .addParam("contract", "The contract's address")
  .addParam("user", "The user's address")
  .addParam("food", "The food amount in ethers", 100, types.int)
  .addParam("wood", "The wood amount in ethers", 100, types.int)
  .addParam("rock", "The stone amount in ethers", 100, types.int)
  .addParam("iron", "The iron amount in ethers", 100, types.int)
  .setAction(async (taskArgs) => {
    let configurationFacet = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);
    console.log("Minting commodities...");
    tx = await configurationFacet.mintCommodities(taskArgs.user, 
      parseEther(taskArgs.food.toString(), 18),
      parseEther(taskArgs.wood.toString(), 18),
      parseEther(taskArgs.rock.toString(), 18),
      parseEther(taskArgs.iron.toString(), 18)
      );
    await tx.wait();
    console.log("Minted");
  });

  task("approveCommodities", "Approve spending user's commodities")
  .addParam("contract", "The contract's address")
  .addParam("user", "The user's address")
  .addParam("food", "The food amount in ethers", 10000000, types.int)
  .addParam("wood", "The wood amount in ethers", 10000000, types.int)
  .addParam("rock", "The stone amount in ethers", 10000000, types.int)
  .addParam("iron", "The iron amount in ethers", 10000000, types.int)
  .setAction(async (taskArgs) => {
    let configurationFacet = await ethers.getContractAt('ConfigurationFacet', taskArgs.contract);
    console.log("Approve commodities...");
    tx = await configurationFacet.approveCommodities(taskArgs.user, 
      parseEther(taskArgs.food.toString(), 18),
      parseEther(taskArgs.wood.toString(), 18),
      parseEther(taskArgs.rock.toString(), 18),
      parseEther(taskArgs.iron.toString(), 18)
      );
    await tx.wait();
    console.log("Approve");
  });



  task("createStructureEvent", "")
  .addParam("contract", "The contract's address")
  .addParam("user", "The user's address")
  .addParam("eventActionId", "", 2, types.int)
  .addParam("assetTypeId", "", 1, types.int)
  .addParam("provinceId", "", 0, types.int)
  .addParam("multiple", "", 1, types.int)
  .addParam("rounds", "", 1, types.int)
  .addParam("hero", "", 0, types.int)
  .setAction(async (taskArgs) => {
    const args = [
       taskArgs.eventActionId,
       taskArgs.assetTypeId,
       BigNumber.from(taskArgs.provinceId),
       BigNumber.from(taskArgs.multiple),
       BigNumber.from(taskArgs.rounds),
       BigNumber.from(taskArgs.hero),
    ];
    const accounts = await ethers.getSigners();
    const contracts = getContracts(1337, accounts[0]);
    console.log("args", args);
    //const contract = await ethers.getContractAt('ProvinceFacet', taskArgs.contract);
    console.log("Creating structure event...");
    const tx = await contracts.provinceFacet.createStructureEvent(args);
    await tx.wait();
    console.log("Done");
  });

// --------------------------------------------------------------
// ConfigurationFacet
// --------------------------------------------------------------
