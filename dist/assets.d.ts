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
};
export declare const cost: {
    manPower: BigNumber;
    attrition: BigNumber;
    penalty: BigNumber;
    time: BigNumber;
    goldForTime: BigNumber;
    manPowerAttrition: BigNumber;
    food: BigNumber;
    wood: BigNumber;
    rock: BigNumber;
    iron: BigNumber;
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
};
export declare const assets: ({
    typeId: number;
    name: string;
    description: string;
    requiredUserLevel: BigNumber;
    requiredAssets: never[];
    image100: string;
    actions: ({
        actionId: number;
        cost: {
            wood: BigNumber;
            manPower: BigNumber;
            attrition: BigNumber;
            penalty: BigNumber;
            time: BigNumber;
            goldForTime: BigNumber;
            manPowerAttrition: BigNumber;
            food: BigNumber;
            rock: BigNumber;
            iron: BigNumber;
        };
        reward: {
            food: BigNumber;
            manPower: BigNumber;
            manPowerAttrition: BigNumber;
            attrition: BigNumber;
            penalty: BigNumber;
            time: BigNumber;
            goldForTime: BigNumber;
            wood: BigNumber;
            rock: BigNumber;
            iron: BigNumber;
        };
        image100: string;
        name: string;
        description: string;
        eventActionId?: undefined;
    } | {
        eventActionId: number;
        cost: {
            manPower: BigNumber;
            time: BigNumber;
            goldForTime: BigNumber;
            food: BigNumber;
            attrition: BigNumber;
            penalty: BigNumber;
            manPowerAttrition: BigNumber;
            wood: BigNumber;
            rock: BigNumber;
            iron: BigNumber;
        };
        reward: {
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
        };
        image100: string;
        name: string;
        description: string;
        actionId?: undefined;
    })[];
} | {
    typeId: number;
    name: string;
    description: string;
    requiredUserLevel: BigNumber;
    requiredAssets: never[];
    image100?: undefined;
    actions?: undefined;
})[];
export declare function getAssetActionData(): any;
export declare function getAssetData(): any;
export declare function getAsset(typeId: any): any;
export declare function getAssetAction(asset: any, actionId: any): any;
export declare function getContracts(chainId: any, signer: any): any;
export declare const baseCostSettings: {
    "1337": {
        provinceLimit: BigNumber;
        baseProvinceCost: BigNumber;
        baseCommodityReward: BigNumber;
        baseGoldCost: BigNumber;
        baseUnit: BigNumber;
        timeBaseCost: BigNumber;
        goldForTimeBaseCost: BigNumber;
        foodBaseCost: BigNumber;
        woodBaseCost: BigNumber;
        rockBaseCost: BigNumber;
        ironBaseCost: BigNumber;
        vassalTribute: BigNumber;
    };
};
//# sourceMappingURL=assets.d.ts.map