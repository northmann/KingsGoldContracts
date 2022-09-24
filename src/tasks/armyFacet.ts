import { task } from "hardhat/config";
import { getArmyUnitTypeRawData, ArmyUnit, ArmyUnitType } from '../army';
import { BigNumber } from 'ethers';



task("getArmy", "Get army data")
  .addParam("diamond", "The contract's address")
  .addParam("id", "The gold amount in ethers")
  .setAction(
    async (taskArgs: any, hre: any) => {
      const contract = await hre.ethers.getContractAt('ArmyFacet', taskArgs.diamond);
      const army = await contract.getArmy(taskArgs.id);
      console.log(army);
    });

// --------------------------------------------------------------------------------------------

task("getProvinceArmies", "Get army data")
  .addParam("diamond", "The contract's address")
  .addParam("provinceid", "The ID of the province")
  .setAction(
    async (taskArgs: any, hre: any) => {
      let armies = await getProvinceArmies(hre, taskArgs.diamond, taskArgs.provinceid);
      console.log(armies);
      return armies;
    });

export async function getProvinceArmies(hre: any, diamondAddress: string, provinceId: number) {
  const contract = await hre.ethers.getContractAt('ArmyFacet', diamondAddress);
  const armies = await contract.getProvinceArmies(provinceId);
  return armies;
}


// --------------------------------------------------------------------------------------------

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

// --------------------------------------------------------------------------------------------

  task("updateGarrison", "Deploys the ArmyUnitTypes")
  .addParam("diamond", "The diamond's address")
  .addParam("provinceid", "The ID of the province")
  .setAction(async (taskArgs: any, hre: any) => {
    const contract = await hre.ethers.getContractAt('ArmyFacet', taskArgs.diamond);

    const arr = [
      {
        armyUnitTypeId:ArmyUnitType.Militia,
        amount: 10,
      },
      {
        armyUnitTypeId: ArmyUnitType.Soldier,
        amount: 12,
      },
      {
        armyUnitTypeId: ArmyUnitType.Archer,
        amount: 8,
      },
      {
        armyUnitTypeId: ArmyUnitType.Knight,
        amount: 3,
      },
      {
        armyUnitTypeId: ArmyUnitType.Catapult,
        amount: 1,
      },
    ];
    

    console.log("Deploying garrison test data...");
    let tx = await contract.updateGarrison(taskArgs.provinceid, arr);
    await tx.wait();
    console.log("Deployed", arr.length, "ArmyUnits");
  });

  