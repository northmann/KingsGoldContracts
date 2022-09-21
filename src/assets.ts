import { BigNumber, ethers } from 'ethers';
import { EventState, EventActionEnum, AssetTypeEnum, AssetProductEnum, eth0_1, eth0_5, eth0, eth1, eth10, eth100, eth2, eth4, eth5, eth50, eth8, eth9  } from './constants';
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
    amount: BigNumber.from(1), // 1 structure
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

const buildAction = {
    eventActionId: EventActionEnum.Build,
    method: "buildStructure(uint256)",
    cost: {
        ...cost,
    },
    reward: {
        ...reward,
    },
    image100: "HouseConstruction100.webp",
    title: "Build",
    description: "Build a structure",
    executeTitle: "Build"
}


const produceAction = {
    eventActionId: EventActionEnum.Produce,
    method: "produceStructure(uint256)",
    cost: {
        ...cost,
    },
    reward: {
        ...reward,
    },
    image100: "HouseConstruction100.webp",
    title: "Produce",
    description: "Produce a resource",
    executeTitle: "Produce"
}


const dismantleAction = {
    eventActionId: EventActionEnum.Dismantle,
    method: "dismantleStructure(uint256)",
    cost: {
        ...cost,
    },
    reward: {
        ...reward,
    },
    image100: "HouseConstruction100.webp",
    title: "Dismantle",
    description: "Dismantle a resource",
    executeTitle: "Dismantle"
}

const burnAction = {
    eventActionId: EventActionEnum.Burn,
    method: "burnStructure(uint256)",
    cost: {
        ...cost,
    },
    reward: {
        ...reward,
    },
    image100: "HouseConstruction100.webp",
    title: "Burn",
    description: "Burn a resource",
    executeTitle: "Burn"
}




export const assets: any = {
    [AssetTypeEnum.None]: {
        typeId: AssetTypeEnum.None,
        productId: AssetProductEnum.None,
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    [AssetTypeEnum.Farm]: {
        typeId: AssetTypeEnum.Farm,
        productId: AssetProductEnum.Structure,
        title: "Farm",
        description: "Produces food",
        image100: "Farm100.png",
        requiredUserLevel: eth0,
        requiredAssets: [],
        actions: {
            [EventActionEnum.Build]:{
                ...buildAction,
                cost: {
                    ...cost,
                    wood: eth50,
                    food: eth0,
                    amount: BigNumber.from(0),
                },
                reward: {
                    ...reward,
                    amount: BigNumber.from(1), // 1 farm
                },
                image100: "HouseConstruction100.webp",
                description: "Build a farm",
            },
            [EventActionEnum.Dismantle]:{
                ...dismantleAction,
                ...dismantleCost,
                description: "Breakdown farms to gain some wood",
            },
            [EventActionEnum.Produce]:{
                ...produceAction,
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
                    amount: BigNumber.from(1), // return available structure
                },
                image100: "farming100.webp",
                title: "Farming",
                description: "Produces food",
            },
            [EventActionEnum.Burn]:{
                ...burnAction,
                ...burnCost,
                description: "Set the farms on fire to destory them. No resources are gained.",
            }
        }
    },
    [AssetTypeEnum.Sawmill]: {
        typeId: AssetTypeEnum.Sawmill,
        productId: AssetProductEnum.Structure,
        title: "Sawmill",
        description: "Greatly increases the production of wood",
        requiredUserLevel: eth0,
        requiredAssets: [],
        image100: "sawmillE100.webp",
        actions: {
            [EventActionEnum.Build]:{
                ...buildAction,
                cost: {
                    ...cost,
                    food: eth50,
                    amount: BigNumber.from(0),
                },
                reward: {
                    ...reward,
                    amount: BigNumber.from(1), // 1 blacksmith
                },
                image100: "sawmillE100.webp",
                description: "Build a sawmill",
            },
            [EventActionEnum.Dismantle]:{
                ...dismantleAction,
                ...dismantleCost,
                reward: {
                    ...reward,
                    wood: eth5,
                },
                description: "Breakdown sawmill to gain some wood",
            },
            [EventActionEnum.Produce]:{
                ...produceAction,
                cost: {
                    ...cost,
                    manPower: BigNumber.from(1),
                    time: BigNumber.from(60 * 60 * 4), // 4 hours,
                },
                reward: {
                    ...reward,
                    wood: eth50,
                    amount: BigNumber.from(1), // return available structure
                },
                image100: "sawmillE100.webp",
                title: "Produce",
                description: "Produces fine wood",
                executeTitle: "Produce",
            },
            [EventActionEnum.Burn]:{
                ...burnAction,
                ...burnCost,
                description: "Set the sawmill on fire to destory it. No resources are gained in the process.",
            }
        },
    },
    [AssetTypeEnum.Blacksmith]:{
        typeId: AssetTypeEnum.Blacksmith,
        productId: AssetProductEnum.Structure,
        title: "Blacksmith",
        description: "Produces iron",
        image100: "Blacksmith100.webp",
        requiredUserLevel: eth0,
        requiredAssets: [],
        actions: {
            [EventActionEnum.Build]:{
                ...buildAction,
                cost: {
                    ...cost,
                    wood: eth50,
                    amount: BigNumber.from(0),
                },
                reward: {
                    ...reward,
                    amount: BigNumber.from(1), // 1 blacksmith
                },
                image100: "HouseConstruction100.webp",
                description: "Build a blacksmith",
            },
            [EventActionEnum.Dismantle]:{
                ...dismantleAction,
                ...dismantleCost,
                reward: {
                    ...reward,
                    wood: eth5,
                    iron: eth5,
                },
                description: "Breakdown blacksmith to gain some wood and iron",
            },
            [EventActionEnum.Produce]:{
                ...produceAction,
                cost: {
                    ...cost,
                    manPower: BigNumber.from(1),
                    time: BigNumber.from(60 * 60 * 4), // 4 hours,
                },
                reward: {
                    ...reward,
                    iron: eth50,
                    amount: BigNumber.from(1), // return available structure
                },
                image100: "Blacksmith100.webp",
                title: "Molding",
                description: "Produces iron",
                executeTitle: "Mold",
            },
            [EventActionEnum.Burn]:{
                ...burnAction,
                ...burnCost,
                description: "Set the blacksmith on fire to destory it. No resources are gained in the process.",
            }
        },
    },
    [AssetTypeEnum.Quarry]: {
        typeId: AssetTypeEnum.Quarry,
        productId: AssetProductEnum.Structure,
        title: "Quarry",
        description: "Greatly increases the production of rock",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    [AssetTypeEnum.Barrack]: {
        typeId: AssetTypeEnum.Barrack,
        productId: AssetProductEnum.Structure,
        title: "Barrack",
        description: "Produces soldiers",
        requiredUserLevel: BigNumber.from(100),
        requiredAssets: [AssetTypeEnum.Farm, AssetTypeEnum.Blacksmith], 
        image100: "HouseConstruction100.webp",
        actions: {
            [EventActionEnum.Build]:{
                ...buildAction,
                cost: {
                    ...cost,
                    manPower: BigNumber.from(2),
                    time: BigNumber.from(60 * 60 * 8), // 8 hours
                    wood: eth100,
                    iron: eth1,
                    food: eth1.mul(8*2), // 8 hours * 2 manPower
                    amount: BigNumber.from(0),
                },
                reward: {
                    ...reward,
                    amount: BigNumber.from(1), // 1 barrack
                },
                image100: "HouseConstruction100.webp",
                description: "Build a barrack",
            },
            [EventActionEnum.Dismantle]:{
                ...dismantleAction,
                ...dismantleCost,
                reward: {
                    ...reward,
                    wood: eth5,
                    iron: eth5,
                },
                description: "Breakdown barrack to gain some wood and iron",
            },
            [EventActionEnum.Produce]:{
                ...produceAction,
                method: "produceSoldier(uint256)",
                cost: {
                    ...cost,
                    manPower: BigNumber.from(1),
                    time: BigNumber.from(60 * 60 * 4), // 4 hours
                },
                reward: {
                    ...reward,
                    amount: BigNumber.from(1), // 1 soldier
                },
                image100: "HouseConstruction100.webp",
                title: "Recruit",
                description: "Recruit soldiers",
                executeTitle: "Recruit",
            },
            [EventActionEnum.Burn]:{
                ...burnAction,
                ...burnCost,
                description: "Set the barrack on fire to destory it. No resources are gained in the process.",
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
                reward: action.reward,
                method: action.method,
            }

            return r;
        });

        if (actions && actions.length > 0)
            assetActions = [...assetActions, ...actions];
    });

    let result = assetActions;
    console.log("assetActions", result);


    return result;
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

export function getAssetsByGroup(productId: AssetProductEnum): any {
    let assetData = Object.keys(assets).filter((key:any) => assets[key].productId === productId).map((key:any) => assets[key]);

    return assetData;
}



export function getAssetAction(asset: any, eventActionId: any): any {
    if (!asset || !eventActionId) return;

    return asset?.actions?.[eventActionId];
}


