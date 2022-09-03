import { BigNumber, ethers, Contract } from 'ethers';
import { parseUnits } from 'ethers/lib/utils';
import contractAddresses from './contractAddresses.json';
import { appSettings } from './appSettings';


import DiamondABI from './abi/Diamond.json';
import KingsGoldABI from './abi/KingsGold.json';
import WoodABI from './abi/Wood.json';
import RockABI from './abi/Rock.json';
import IronABI from './abi/Iron.json';
import FoodABI from './abi/Food.json';
import UserFacetABI from './abi/UserFacet.json';
import TreasuryFacetABI from './abi/TreasuryFacet.json';
import ProvinceFacet from './abi/ProvinceFacet.json';


const eth0_1 = parseUnits("0.1", "ether");
const eth0_5 = parseUnits("0.5", "ether");
const eth0 = BigNumber.from(0);
const eth1 = parseUnits("1.0", "ether");
const eth2 = parseUnits("2.0", "ether");
const eth4 = parseUnits("4.0", "ether");
const eth5 = parseUnits("5.0", "ether");
const eth8 = parseUnits("4.0", "ether");
const eth9 = parseUnits("1.0", "ether");
const eth10 = parseUnits("10.0", "ether");
const eth50 = parseUnits("50.0", "ether"); // 100 mill eth
const eth100 = parseUnits("100.0", "ether"); // 100 mill eth


export const EventState = {
    Active: 0,
    PaidFor: 1,
    Completed: 2,
    Cancelled: 3
}

export const EventActionEnum = {
    Build: 0,
    Dismantle: 1,
    Produce: 2,
    Burn: 3
}

export const AssetTypeEnum = {
    None: 0,
    Farm: 1,
    Sawmill: 2,
    Blacksmith: 3,
    Quarry: 4,
    Barrack: 5,
    Stable: 6,
    Market: 7,
    Temple: 8,
    University: 9,
    Wall: 10,
    Watchtower: 11,
    Castle: 12,
    Fortress: 13,
    Population: 14
}

export const AssetGroupEnum = {
    None: 0,
    Structure: 1,
    Population: 2,
    Commodity: 3,
    Artifact: 4
}

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


export const assets: any = [
    {
        typeId: AssetTypeEnum.None,
        groupId: AssetGroupEnum.None,
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: AssetTypeEnum.Farm,
        groupId: AssetGroupEnum.Structure,
        title: "Farm",
        description: "Produces food",
        requiredUserLevel: eth0,
        requiredAssets: [],
        image100: "Farm100.png",
        actions: [
            {
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
                description: "Build a farm",
            },
            {
                ...dismantleCost,
                description: "Breakdown farms to gain some wood",
            },
            {
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
                description: "Produces food 4",
            },
            {
                ...burnCost,
                description: "Set the farms on fire to destory them. No resources are gained.",
            }
        ],
    },
    {
        typeId: AssetTypeEnum.Sawmill,
        groupId: AssetGroupEnum.Structure,
        title: "Sawmill",
        description: "Greatly increases the production of wood",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: AssetTypeEnum.Blacksmith,
        groupId: AssetGroupEnum.Structure,
        title: "Blacksmith",
        description: "Produces iron",
        requiredUserLevel: eth0,
        requiredAssets: [],
        image100: "Blacksmith100.webp",
        actions: [
            {
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
            {
                ...dismantleCost,
                reward: {
                    ...reward,
                    wood: eth5,
                    iron: eth5,
                },
                description: "Breakdown blacksmith to gain some wood and iron",
            },
            {
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
            {
                ...burnCost,
                description: "Set the blacksmith on fire to destory it. No resources are gained in the process.",
            }
        ],
    },
    {
        typeId: AssetTypeEnum.Quarry,
        groupId: AssetGroupEnum.Structure,
        title: "Quarry",
        description: "Greatly increases the production of rock",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: AssetTypeEnum.Barrack,
        groupId: AssetGroupEnum.Structure,
        title: "Barrack",
        description: "Produces soldiers",
        requiredUserLevel: BigNumber.from(100),
        requiredAssets: [AssetTypeEnum.Farm, AssetTypeEnum.Blacksmith], 
    },
];


export function getAssetActionData(): any {

    let assetActions = new Array<any>();
    assets.forEach((asset:any) => {
        if (!asset.actions) return;

        let actions = asset?.actions?.map((action:any) => {
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

    //let assetActions = [].concat(...arr);


    return assetActions;
}

export function getAssetData(): any {

    let result = assets.map((asset:any) => {
        let r = { ...asset };
        delete r.actions;
        delete r.title;
        delete r.description;
        delete r.image100;
        return r;
    });

     return result;
}

export function getAsset(typeId: any): any {
    return assets?.find((a: any) => a.typeId === typeId);
}



export function getAssetAction(asset: any, eventActionId: any): any {
    if (!asset || !eventActionId) return;
    return asset?.actions?.find((a: any) => a.eventActionId === eventActionId);
}


export function getContracts(chainId: any, signer: any) : any {
    let result: any = {};

    result.diamond = new Contract(contractAddresses["Diamond"], DiamondABI, signer);
    result.kingsGold = new Contract(contractAddresses["KingsGold"], KingsGoldABI, signer);
    result.wood = new Contract(contractAddresses["Wood"], WoodABI, signer);
    result.rock = new Contract(contractAddresses["Rock"], RockABI, signer);
    result.iron = new Contract(contractAddresses["Iron"], IronABI, signer);
    result.food = new Contract(contractAddresses["Food"], FoodABI, signer);
    result.userFacet = new Contract(contractAddresses["Diamond"], UserFacetABI, signer);
    result.treasuryFacet = new Contract(contractAddresses["Diamond"], TreasuryFacetABI, signer);
    result.provinceFacet = new Contract(contractAddresses["Diamond"], ProvinceFacet, signer);

    return result;
}


export function getAppSettings(chainId: number) : any {
    return { ...appSettings.generic, ...appSettings[chainId]};
}