import { task } from "hardhat/config";

import { HardhatRuntimeEnvironment } from "hardhat/types";

import { getSigner, getFunctionSignatures, deployContract } from "../lib/utils";


// ----------------------------------------

task("functionSignatures", "Prints function signatures")
  .addParam("name", "The contract's name")
  .setAction(
    async (taskArgs: any, hre: any) => {

      const contract = await hre.ethers.getContractFactory(taskArgs.name);

      const signatures = Object.keys(contract.interface.functions)
      signatures.forEach((v, i, a) => {

        let sig = contract.interface.getSighash(v);
        console.log(v, ' : ', sig);
      });
    });


// ----------------------------------------

interface DeployFacetTaskArgs {
  diamond: string;
  facet: string;
  useledger: boolean;
}

task("deployFacet", "deploy a facet")
  .addParam("diamond", "The diamond address")
  .addParam("facet", "The contract's name")
  .addFlag("useledger", "Set to true if Ledger should be used for signing")

  .setAction(
    async (taskArgs: DeployFacetTaskArgs, hre: any) => {

      console.log("Logon taskArgs: ", taskArgs);

      const diamondAddress: string = taskArgs.diamond;
      const facetName: string = taskArgs.facet;
      const useLedger = taskArgs.useledger;


      //Instantiate the Signer
      let signer = await getSigner(hre, diamondAddress, useLedger);

      let facet = await deployFacets(hre, diamondAddress, [facetName], signer);

      return facet;
    }
  );

export async function deployFacets(hre: any, diamondAddress: string, facetNames: string[], signer: any) {

  let cut: any = [];

  for (let i = 0; i < facetNames.length; i++) {

    let facetName = facetNames[i];
    let facet = await deployContract(hre, facetName, signer);

    console.log('Deploy facet:', facetName, ' with address:', facet.address);

    cut.push({
      facetAddress: facet.address,
      facetName: facetName,
      functionSignatures: getFunctionSignatures(facet)
    });
  }

  const diamondCut = await hre.ethers.getContractAt('IDiamondCut', diamondAddress, signer);

  // call to init function
  let tx = await diamondCut.diamondCut(cut, hre.ethers.constants.AddressZero, "0x"); // , { gasLimit: 30000000}
  let receipt = await tx.wait();
  if (!receipt.status) {
    throw Error(`Diamond upgrade failed: ${tx.hash}`);
  }

  console.log('Diamond upgrade successful. Cuts:', cut);

}

// ----------------------------------------



task("facets", "Prints all facets")
  //  .addParam("name", "The contract's name")
  .setAction(
    async (taskArgs: any, hre: HardhatRuntimeEnvironment) => {


      const names = await hre.artifacts.getAllFullyQualifiedNames();

      names.forEach((v: string, i: any) => {
        const arr = v.split(':');
        const path = arr[0];
        const name = arr[1];
        if (!path.startsWith('contracts/game/') || !name.endsWith('Facet'))
          return;

        console.log(name);
      });
    });

// --------------------------------------------------------------------------------------------

task("deployAllGameFacets", "Deploy all facets")
  .addParam("diamond", "The diamond address")
  .addFlag("useledger", "Set to true if Ledger should be used for signing")
  .setAction(
    async (taskArgs: any, hre: HardhatRuntimeEnvironment) => {
        
        //Instantiate the Signer
        let signer = await getSigner(hre, taskArgs.diamond, taskArgs.useledger);
 
        await deployAllGameFacets(hre, taskArgs.diamond, signer);
    });

export async function deployAllGameFacets(hre: HardhatRuntimeEnvironment, diamondAddress: string, signer: any) {
  
    const names = await hre.artifacts.getAllFullyQualifiedNames();

    const facetNames = names.map((v: string) => {
      const arr = v.split(':');
      const path = arr[0];
      const name = arr[1];
      if (!path.startsWith('contracts/game/') || !name.endsWith('Facet'))
        return '';
      
        return name;
    }).filter((v: string) => v.length > 0);

    await deployFacets(hre, diamondAddress, facetNames, signer);
}

// --------------------------------------------------------------------------------------------

task("deployDiamondCore", "Deploy core diamond")
  .addFlag("useledger", "Set to true if Ledger should be used for signing")
  .setAction(
    async (taskArgs: any, hre: HardhatRuntimeEnvironment) => {

      //Instantiate the Signer
      let signer = await getSigner(hre, undefined, taskArgs.useledger);
      return await deployDiamondCore(hre, signer);
    });

export async function deployDiamondCore(hre: any, signer: any): Promise<string> {
  let diamondCutFacet = await deployContract(hre, 'DiamondCutFacet', signer);
  // deploy Diamond
  const owner = await signer.getAddress();
  let diamond = await deployContract('Diamond', owner, diamondCutFacet.address);

  //console.log('Diamond deployed to:', diamond.address);
  return diamond.address;
}

// --------------------------------------------------------------------------------------------
