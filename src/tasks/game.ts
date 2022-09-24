import { task } from "hardhat/config";

import { HardhatRuntimeEnvironment } from "hardhat/types";

import { getSigner, getFunctionSignatures, deployContract } from "../lib/utils";
import { deployAllGameFacets, deployDiamondCore } from "./diamondCutFacet";


// --------------------------------------------------------------------------------------------

task("deployGame", "Deploy the core game")
  .addFlag("useledger", "Set to true if Ledger should be used for signing")
  .setAction(
    async (taskArgs: any, hre: HardhatRuntimeEnvironment) => {

      //Instantiate the Signer
      let signer = await getSigner(hre, undefined, taskArgs.useledger);
      return deployCoreGame(hre, signer);
    });

export async function deployCoreGame(hre: any, signer: any): Promise<string> {
    
      const diamondAddress = await deployDiamondCore(hre, signer);
      await deployAllGameFacets(hre, diamondAddress, signer);

      return diamondAddress;
}
