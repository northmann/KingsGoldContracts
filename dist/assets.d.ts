import { BigNumber } from 'ethers';
export declare const EventState: {
    Active: number;
    PaidFor: number;
    Completed: number;
    Cancelled: number;
};
export declare const EventActionEnum: {
    Build: number;
    Dismantle: number;
    Produce: number;
    Burn: number;
};
export declare const AssetTypeEnum: {
    None: number;
    Farm: number;
    Sawmill: number;
    Blacksmith: number;
    Quarry: number;
    Barrack: number;
    Stable: number;
    Market: number;
    Temple: number;
    University: number;
    Wall: number;
    Watchtower: number;
    Castle: number;
    Fortress: number;
    Population: number;
};
export declare const AssetGroupEnum: {
    None: number;
    Structure: number;
    Population: number;
    Commodity: number;
    Artifact: number;
};
export declare const zeroCost: {
    manPower: BigNumber;
    manPowerAttrition: BigNumber;
    attrition: BigNumber;
    penalty: BigNumber;
    time: BigNumber;
    goldForTime: BigNumber;
    food: BigNumber;
    wood: BigNumber;
    rock: BigNumber;
    iron: BigNumber;
    gold: BigNumber;
    amount: BigNumber;
};
export declare const cost: {
    manPower: BigNumber;
    attrition: BigNumber;
    penalty: BigNumber;
    manPowerAttrition: BigNumber;
    time: BigNumber;
    goldForTime: BigNumber;
    food: BigNumber;
    wood: BigNumber;
    rock: BigNumber;
    iron: BigNumber;
    gold: BigNumber;
    amount: BigNumber;
};
export declare const reward: {
    manPower: BigNumber;
    manPowerAttrition: BigNumber;
    attrition: BigNumber;
    penalty: BigNumber;
    time: BigNumber;
    goldForTime: BigNumber;
    food: BigNumber;
    wood: BigNumber;
    rock: BigNumber;
    iron: BigNumber;
    gold: BigNumber;
    amount: BigNumber;
};
export declare const assets: any;
export declare function getAssetActionData(): any;
export declare function getAssetData(): any;
export declare function getAsset(typeId: any): any;
export declare function getAssetAction(asset: any, eventActionId: any): any;
export declare function getContracts(chainId: any, signer: any): any;
export declare function getAppSettings(chainId: number): any;
//# sourceMappingURL=assets.d.ts.map