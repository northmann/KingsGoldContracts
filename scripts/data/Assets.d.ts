export namespace AssetType {
    const None: number;
    const Farm: number;
    const Sawmill: number;
    const Blacksmith: number;
    const Quarry: number;
    const Barrack: number;
    const Stable: number;
    const Market: number;
    const Temple: number;
    const University: number;
    const Wall: number;
    const Watchtower: number;
    const Castle: number;
    const Fortress: number;
    const Population: number;
}
export namespace EventState {
    const Active: number;
    const PaidFor: number;
    const Completed: number;
    const Cancelled: number;
}
export namespace EventAction {
    const Build: number;
    const Dismantle: number;
    const Produce: number;
    const Burn: number;
}
export namespace zeroCost {
    export { eth0 as manPower };
    export { eth0 as manPowerAttrition };
    export { eth0 as attrition };
    export { eth0 as penalty };
    export { eth0 as time };
    export { eth0 as goldForTime };
    export { eth0 as food };
    export { eth0 as wood };
    export { eth0 as rock };
    export { eth0 as iron };
}
export namespace cost {
    export const manPower: BigNumber;
    export { eth0_1 as attrition };
    export { eth0_5 as penalty };
    export const time: BigNumber;
    export { eth1 as goldForTime };
}
export namespace reward { }
export const assets: ({
    typeId: number;
    name: string;
    description: string;
    requiredUserLevel: BigNumber;
    requiredAssets: never[];
    actions: ({
        eventActionId: number;
        cost: {
            manPower: number;
            wood: BigNumber;
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
    } | {
        eventActionId: number;
        cost: {
            manPower: number;
            time: number;
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
            wood: BigNumber;
            manPower: BigNumber;
            manPowerAttrition: BigNumber;
            attrition: BigNumber;
            penalty: BigNumber;
            time: BigNumber;
            goldForTime: BigNumber;
            food: BigNumber;
            rock: BigNumber;
            iron: BigNumber;
        };
        image100?: undefined;
        name?: undefined;
        description?: undefined;
    } | {
        eventActionId: number;
        cost: {
            manPower: number;
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
        image100?: undefined;
        name?: undefined;
        description?: undefined;
    })[];
} | {
    typeId: number;
    name: string;
    description: string;
    requiredUserLevel: BigNumber;
    requiredAssets: never[];
    actions?: undefined;
})[];
export function getAssetData(): ({
    typeId: number;
    name: string;
    description: string;
    requiredUserLevel: BigNumber;
    requiredAssets: never[];
    actions: ({
        eventActionId: number;
        cost: {
            manPower: number;
            wood: BigNumber;
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
    } | {
        eventActionId: number;
        cost: {
            manPower: number;
            time: number;
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
            wood: BigNumber;
            manPower: BigNumber;
            manPowerAttrition: BigNumber;
            attrition: BigNumber;
            penalty: BigNumber;
            time: BigNumber;
            goldForTime: BigNumber;
            food: BigNumber;
            rock: BigNumber;
            iron: BigNumber;
        };
        image100?: undefined;
        name?: undefined;
        description?: undefined;
    } | {
        eventActionId: number;
        cost: {
            manPower: number;
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
        image100?: undefined;
        name?: undefined;
        description?: undefined;
    })[];
} | {
    typeId: number;
    name: string;
    description: string;
    requiredUserLevel: BigNumber;
    requiredAssets: never[];
    actions?: undefined;
})[];
export function getAssetActionData(): any[];
export function getAsset(typeId: any): {
    typeId: number;
    name: string;
    description: string;
    requiredUserLevel: BigNumber;
    requiredAssets: never[];
    actions: ({
        eventActionId: number;
        cost: {
            manPower: number;
            wood: BigNumber;
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
    } | {
        eventActionId: number;
        cost: {
            manPower: number;
            time: number;
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
            wood: BigNumber;
            manPower: BigNumber;
            manPowerAttrition: BigNumber;
            attrition: BigNumber;
            penalty: BigNumber;
            time: BigNumber;
            goldForTime: BigNumber;
            food: BigNumber;
            rock: BigNumber;
            iron: BigNumber;
        };
        image100?: undefined;
        name?: undefined;
        description?: undefined;
    } | {
        eventActionId: number;
        cost: {
            manPower: number;
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
        image100?: undefined;
        name?: undefined;
        description?: undefined;
    })[];
} | {
    typeId: number;
    name: string;
    description: string;
    requiredUserLevel: BigNumber;
    requiredAssets: never[];
    actions?: undefined;
} | undefined;
export function getAssetAction(asset: any, actionId: any): any;
declare const eth0: BigNumber;
import { BigNumber } from "ethers";
declare const eth0_1: BigNumber;
declare const eth0_5: BigNumber;
declare const eth1: BigNumber;
export {};
//# sourceMappingURL=Assets.d.ts.map