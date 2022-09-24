//import { parseUnits, BigNumber } from 'ethers';

//import { Signer } from "@ethersproject/abstract-signer";
import { LedgerSigner } from "@northmann/ethers-ledger";
import { BigNumber } from "ethers";
import { parseUnits } from "ethers/lib/utils";


export async function setBalance(hre: any, signer: any, amount: BigNumber) {
  
  await hre.network.provider.request({
    method: "hardhat_setBalance",
    params: [signer, amount.toHexString()],
  });
}


export async function getSigner(hre: any, diamondAddress: string | undefined, useledger: any) {
    //Instantiate the Signer
    let signer: any;
  
    const testing = ["hardhat", "localhost"].includes(hre.network.name);
    console.log("network is testing: ", testing);
  
    console.log("Using Ledger: ", useledger);
    if (useledger) {
      // m / purpose' / coin_type' / account' / change / address_index
      // m/44'/60'/0'/0/0
      // Metamask uses m/44'/60'/(account)'/0/(address index)
  
      //signer = new LedgerSigner(hre.ethers.provider, "hid", "m/44'/60'/100'/0/0");
      signer = new LedgerSigner(hre.ethers.provider, "m/44'/60'/100'/0/0");
      if(testing) {
        console.log("signer address: ", await signer.getAddress());
          const owner = await signer.getAddress();
  
          console.log("adding balance to owner: ", owner);
          const value = parseUnits("0x100000000000000000000000", 1); // 100
          setBalance(hre, owner, value);
          // await hre.network.provider.request({
          //   method: "hardhat_setBalance",
          //   params: [owner, "0x100000000000000000000000"],
          // });
  
  
          // const feeData = await hre.ethers.provider.getFeeData();
          // //const feeDataInEth = hre.ethers.utils.formatEther(feeData);
          // console.log(`feeData: `, feeData);
  
          let balance = await hre.ethers.provider.getBalance(owner);
          // convert a currency unit from wei to ether
          const balanceInEth = hre.ethers.utils.formatEther(balance);
          console.log(`balance: ${balanceInEth} ETH`)
           
  
      }
      
      //signer = new LedgerSigner(hre.ethers.provider, `m/44'/60'/0'/0/0`);
      //signer = new LedgerSigner(hre.ethers.provider, "m/44'/60'/100'/0/0");
      //signer = new LedgerSigner();
  
      console.log("Ledger Signer: ", await signer.getAddress());
      //console.log("Ledger Signer: ", await signer.getBalance());
  
      return signer;
    } 
  
    if(diamondAddress) {
      console.log("loading owner from diamondAddress: ", diamondAddress);
      const ownershipFacet = await hre.ethers.getContractAt("OwnershipFacet", diamondAddress);
      const owner = await ownershipFacet.owner();
  
      if(owner && owner != "0x0000000000000000000000000000000000000000") {
        await hre.network.provider.request({
          method: "hardhat_impersonateAccount",
          params: [owner],
        });
  
        await hre.network.provider.request({
          method: "hardhat_setBalance",
          params: [owner, "0x100000000000000000000000"],
        });
  
        signer = await hre.ethers.getSigner(owner);
  
        console.log("Owner ImpersonateAccount Signer: ", await signer.getAddress());
  
        return signer;
      }
    }
  
    signer = await hre.ethers.getSigner();
    console.log("Default hardhat Signer: ", await signer.getAddress());

    return signer;
  }
  
  
  export function getFunctionSignatures(contract: any) : string[] {
    const signatures = Object.keys(contract.interface.functions)
    const names = signatures.reduce((acc: any, val: string) => {
        if (val !== 'init(bytes)') {
            acc.push(val)
        }
        return acc
    }, [])
    return names;
  }

  
export async function deployContract(hre: any, contractName: any, signer: any, ...args: any) {
  const Contract = await hre.ethers.getContractFactory(contractName, signer);
  const instance = await Contract.deploy(...args);
  console.log(`${contractName} contract deployed to ${instance.address}`);

  return instance;
}