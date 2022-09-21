import { task } from "hardhat/config";
import { getArmyUnitTypeRawData } from '../army';



task("getArmy", "Get army data")
  .addParam("diamond", "The contract's address")
  .addParam("id", "The gold amount in ethers")
  .setAction(
    async (taskArgs: any, hre: any) => {
      const contract = await hre.ethers.getContractAt('ArmyFacet', taskArgs.diamond);
      const army = await contract.getArmy(taskArgs.id);
      console.log(army);
    });


task("setAppStoreArmyUnitTypes", "Deploys the ArmyUnitTypes")
  .addParam("diamond", "The diamond's address")
  .setAction(async (taskArgs: any, hre: any) => {
    const contract = await hre.ethers.getContractAt('ConfigurationFacet', taskArgs.diamond);

    const arr = getArmyUnitTypeRawData();

    console.log("Deploying ArmyUnitType RawData...");
    let tx = await contract.setAppStoreArmyUnitTypes(arr);
    await tx.wait();
    console.log("Deployed", arr.length, "ArmyUnitTypes");
  });
