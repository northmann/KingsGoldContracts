import { task } from "hardhat/config";

task(
    "owner",
    "Get the owner of the diamond"
  )
    .addParam("diamond", "Address of the Diamond to upgrade")
    .setAction(
      async (taskArgs: any, hre: any) => {
        const diamondAddress: string = taskArgs.diamond;

        const ownershipFacet = await hre.ethers.getContractAt("OwnershipFacet", diamondAddress);
        const owner = await ownershipFacet.owner();
        console.log(owner);
      }
  );