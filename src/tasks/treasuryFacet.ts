import { task } from "hardhat/config";
import { getSigner, setBalance } from "../lib/utils";
import { BigNumber } from 'ethers';
import { parseUnits } from "ethers/lib/utils";


// --------------------------------------------------------------------------------------------

task("setEthBalance", "Set the eth balance of an account")
  .addParam("account", "The account's address")
  .addParam("amount", "The amount in ethers")
  .addFlag("useledger", "Set to true if Ledger should be used for signing")
  .setAction(
    async (taskArgs: any, hre: any) => {

      //Instantiate the Signer
      let signer = await getSigner(hre, taskArgs.account, taskArgs.useledger);
      setBalance(hre, signer, taskArgs.amount);

    });

// --------------------------------------------------------------------------------------------

task("buyGold", "Buy gold from the treasury")
  .addParam("diamond", "The diamond address")
  .addParam("amount", "The amount in ethers")
  .addFlag("useledger", "Set to true if Ledger should be used for signing")
  .setAction(
    async (taskArgs: any, hre: any) => {

      //Instantiate the Signer
      let signer = await getSigner(hre, taskArgs.diamond, taskArgs.useledger);
      const value = parseUnits(taskArgs.amount.toString(), 18); // 100

      buyGold(hre, taskArgs.diamond, signer, value);
      //setBalance(hre, signer, taskArgs.amount);

    });


export async function buyGold(hre: any, diamondAddress: string, signer: any, amount: BigNumber) {
  let treasuryFacet = await hre.ethers.getContractAt('TreasuryFacet', diamondAddress, signer);

  let tx = await treasuryFacet.buy({ value: amount });
  await tx.wait();
}

// --------------------------------------------------------------------------------------------

task("approveGold2", "Approve gold")
  .addParam("diamond", "The diamond address. The diamond knows the gold contract address")
  .addParam("amount", "The amount in ethers")
  .addFlag("useledger", "Set to true if Ledger should be used for signing")
  .setAction(
    async (taskArgs: any, hre: any) => {

      //Instantiate the Signer
      let signer = await getSigner(hre, taskArgs.diamond, taskArgs.useledger);
      const value = parseUnits(taskArgs.amount.toString(), 18); // 100

      approveGold(hre, taskArgs.diamond, signer, value);
      //setBalance(hre, signer, taskArgs.amount);

    });


export async function approveGold(hre: any, diamondAddress: string, signer: any, amount: BigNumber) {

  let settingsContract = await hre.ethers.getContractAt('ConfigurationFacet', diamondAddress, signer);
  let settings = await settingsContract.getBaseSettings();

  // Approve the diamond contract to spend the gold
  let userGoldInstance = await hre.ethers.getContractAt('KingsGold', settings.gold, signer);
  let approveTx = await userGoldInstance.approve(diamondAddress, amount);
  await approveTx.wait();

}

// --------------------------------------------------------------------------------------------
