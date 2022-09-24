import { BigNumber } from "ethers";
export declare function setBalance(hre: any, signer: any, amount: BigNumber): Promise<void>;
export declare function getSigner(hre: any, diamondAddress: string | undefined, useledger: any): Promise<any>;
export declare function getFunctionSignatures(contract: any): string[];
export declare function deployContract(hre: any, contractName: any, signer: any, ...args: any): Promise<any>;
//# sourceMappingURL=utils.d.ts.map