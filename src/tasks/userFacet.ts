import { task } from "hardhat/config";

task("getUser", "Prints an user json data")
  .addParam("contract", "The contract's address")
  .addParam("account", "The account's address")
  .setAction(
    async (taskArgs: any, hre: any) => {
    const contract = await hre.ethers.getContractAt('UserFacet', taskArgs.contract);
    const user = await contract.getUser(taskArgs.account);
    console.log(user);
  });

