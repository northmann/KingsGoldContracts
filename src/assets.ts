import { BigNumber, ethers } from 'ethers';
import { EventState, EventActionEnum, AssetTypeEnum, AssetGroupEnum, eth0_1, eth0_5, eth0, eth1, eth10, eth100, eth2, eth4, eth5, eth50, eth8, eth9  } from './constants';
import { parseUnits } from 'ethers/lib/utils';


export const zeroCost = {
    manPower: BigNumber.from(0),
    manPowerAttrition: eth0,
    attrition: eth0,
    penalty: eth0,
    time: eth0,
    goldForTime: eth0,
    food: eth0,
    wood: eth0,
    rock: eth0,
    iron: eth0,
    gold: eth0,
    amount: eth0, // used for building and burning
}

export const cost = {
    ...zeroCost,
    manPower: BigNumber.from(1),
    attrition: eth0_1,
    penalty: eth0_5,
    // time: BigNumber.from(60 * 60 * 1), // 1 hours standard
    // goldForTime is calculated in the contract
    food: eth1, // It cost 1 food per one manPower per hour
}

export const reward = {
    ...zeroCost,
}

const dismantleCost = {
    eventActionId: EventActionEnum.Dismantle,
    cost: {
        ...cost,
        manPower: BigNumber.from(2),
    },
    reward: {
        ...reward,
        wood: eth10,
    },
    image100: "HouseConstruction100.webp",
    title: "Dismante",
    description: "Breakdown structure to gain some wood",
    executeTitle: "Dismantle",
}

const burnCost = {
    eventActionId: EventActionEnum.Burn,
    cost: {
        ...cost,
        manPower: BigNumber.from(1),
        time: BigNumber.from(60), // 1 minute
        food: eth0, // It cost no food to burn down a farm
    },
    reward: {
        ...zeroCost, // No reward
    },
    image100: "HouseConstruction100.webp",
    title: "Burn",
    description: "Set the structure on fire to destory it. No resources are gained in the process.",
    executeTitle: "Burn",
}


export const assets: any = {
    [AssetTypeEnum.None]: {
        typeId: AssetTypeEnum.None,
        groupId: AssetGroupEnum.None,
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    [AssetTypeEnum.Farm]: {
        typeId: AssetTypeEnum.Farm,
        groupId: AssetGroupEnum.Structure,
        title: "Farm",
        description: "Produces food",
        image100: "Farm100.png",
        requiredUserLevel: eth0,
        requiredAssets: [],
        actions: {
            [EventActionEnum.Build]:{
                eventActionId: EventActionEnum.Build,
                cost: {
                    ...cost,
                    wood: eth50,
                    food: eth0,
                },
                reward: {
                    ...reward,
                    amount: BigNumber.from(1), // 1 farm
                },
                image100: "HouseConstruction100.webp",
                title: "Build",
                description: "Build a farm",
            },
            [EventActionEnum.Dismantle]:{
                ...dismantleCost,
                description: "Breakdown farms to gain some wood",
            },
            [EventActionEnum.Produce]:{
                eventActionId: EventActionEnum.Produce,
                cost: {
                    ...cost,
                    manPower: BigNumber.from(1),
                    time: BigNumber.from(60 * 60 * 4), // 4 hours
                    // goldForTime - Auto calculated from (1 manPower * 4 hours) = 4 gold 
                    food: eth0, // It cost no food to produce food
                },
                reward: {
                    ...reward,
                    food: eth50,
                },
                image100: "farming100.webp",
                title: "Farming",
                description: "Produces food",
            },
            [EventActionEnum.Burn]:{
                ...burnCost,
                description: "Set the farms on fire to destory them. No resources are gained.",
            }
        }
    },
    [AssetTypeEnum.Sawmill]: {
        typeId: AssetTypeEnum.Sawmill,
        groupId: AssetGroupEnum.Structure,
        title: "Sawmill",
        description: "Greatly increases the production of wood",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    [AssetTypeEnum.Blacksmith]:{
        typeId: AssetTypeEnum.Blacksmith,
        groupId: AssetGroupEnum.Structure,
        title: "Blacksmith",
        description: "Produces iron",
        image100: "Blacksmith100.webp",
        requiredUserLevel: eth0,
        requiredAssets: [],
        actions: {
            [EventActionEnum.Build]:{
                eventActionId: EventActionEnum.Build,
                cost: {
                    ...cost,
                    wood: eth50,
                },
                reward: {
                    ...reward,
                    amount: BigNumber.from(1), // 1 farm
                },
                image100: "HouseConstruction100.webp",
                title: "Build",
                description: "Build a blacksmith",
            },
            [EventActionEnum.Dismantle]:{
                ...dismantleCost,
                reward: {
                    ...reward,
                    wood: eth5,
                    iron: eth5,
                },
                description: "Breakdown blacksmith to gain some wood and iron",
            },
            [EventActionEnum.Produce]:{
                eventActionId: EventActionEnum.Produce,
                cost: {
                    ...cost,
                    manPower: BigNumber.from(1),
                    time: BigNumber.from(60 * 60 * 4), // 4 hours
                },
                reward: {
                    ...reward,
                    iron: eth50,
                },
                image100: "Blacksmith100.webp",
                title: "Molding",
                description: "Produces iron",
                executeTitle: "Mold",
            },
            [EventActionEnum.Burn]:{
                ...burnCost,
                description: "Set the blacksmith on fire to destory it. No resources are gained in the process.",
            }
        },
    },
    [AssetTypeEnum.Quarry]: {
        typeId: AssetTypeEnum.Quarry,
        groupId: AssetGroupEnum.Structure,
        title: "Quarry",
        description: "Greatly increases the production of rock",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    [AssetTypeEnum.Barrack]: {
        typeId: AssetTypeEnum.Barrack,
        groupId: AssetGroupEnum.Structure,
        title: "Barrack",
        description: "Produces soldiers",
        requiredUserLevel: BigNumber.from(100),
        requiredAssets: [AssetTypeEnum.Farm, AssetTypeEnum.Blacksmith], 
        actions: {
            [EventActionEnum.Build]:{
                eventActionId: EventActionEnum.Build,
                cost: {
                    ...cost,
                    manPower: BigNumber.from(2),
                    time: BigNumber.from(60 * 60 * 8), // 8 hours
                    wood: eth100,
                    iron: eth1,
                    food: eth1.mul(8*2), // 8 hours * 2 manPower
                },
                reward: {
                    ...reward,
                    amount: BigNumber.from(1), // 1 barrack
                },
                image100: "HouseConstruction100.webp",
                title: "Build",
                description: "Build a barrack",
            },
        },
    },
}


export function getAssetActionData(): any {

    let assetActions = new Array<any>();
    Object.keys(assets).forEach((assetKey:any) => {
        const asset = assets[assetKey];
        if (!asset.actions) return;

        let actions = Object.keys(asset.actions).map((key:any) => {
            let action = asset.actions[key];
            let r = {
                assetTypeId: asset.typeId,
                eventActionId: action.eventActionId,
                cost: action.cost,
                reward: action.reward
            }

            return r;
        });

        if (actions && actions.length > 0)
            assetActions = [...assetActions, ...actions];
    });
    console.log("assetActions", assetActions);

    return assetActions;
}

export function getAssetData(): any {
    let assetData = Object.keys(assets).map((key:any) => 
    {
        let r = { ...assets[key] };
        delete r.actions;
        delete r.title;
        delete r.description;
        delete r.image100;
        return r;
    } );

     return assetData;
}

export function getAsset(typeId: AssetTypeEnum): any {
    return assets?.[typeId];
}

export function getAssetsByGroup(groupId: AssetGroupEnum): any {
    let assetData = Object.keys(assets).filter((key:any) => assets[key].groupId === groupId).map((key:any) => assets[key]);

    return assetData;
}



export function getAssetAction(asset: any, eventActionId: any): any {
    if (!asset || !eventActionId) return;

    return asset?.actions?.[eventActionId];
}


