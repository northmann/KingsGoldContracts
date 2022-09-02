import { BigNumber, ethers, Contract } from 'ethers';
import { parseUnits } from 'ethers/lib/utils';
import contractAddresses from './contractAddresses.json';


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

export const zeroCost = {
    manPower: BigNumber.from(0),
    manPowerAttrition: eth0,
    attrition: eth0,
    penalty: eth0,
    time: BigNumber.from(0),
    goldForTime: eth0,
    food: eth0,
    wood: eth0,
    rock: eth0,
    iron: eth0
}

export const cost = {
    ...zeroCost,
    manPower: BigNumber.from(10),
    attrition: eth0_1,
    penalty: eth0_5,
    time: BigNumber.from(60 * 60 * 4), // 4 hours
    goldForTime: eth1,
}

export const reward = {
    ...zeroCost,
}

export const assets = [
    {
        typeId: AssetTypeEnum.Farm,
        name: "Farm",
        description: "Greatly increases the production of food",
        requiredUserLevel: eth0,
        requiredAssets: [],
        image100: "Farm100.png",
        actions: [
            {
                actionId: EventActionEnum.Build,
                cost: {
                    ...cost,
                    wood: eth50,
                },
                reward: {
                    ...reward,
                    food: eth100,
                },
                image100: "HouseConstruction100.webp",
                name: "Build",
                description: "Build a farm",
            },
            {
                actionId: EventActionEnum.Dismantle,
                cost: {
                    ...cost,
                    manPower: BigNumber.from(2),
                    //time: BigNumber.from(60 * 5), // 5 minutes
                    //goldForTime: eth0, // Auto calculated from (time * manPower)
                    //food: eth0 // Auto calculated from (time * manPower)
                },
                reward: {
                    ...reward,
                    wood: eth10,
                },
                image100: "HouseConstruction100.webp",
                name: "Dismante",
                description: "Breakdown farms to gain some wood",
            },
            {
                actionId: EventActionEnum.Produce,
                cost: {
                    ...cost,
                    manPower: BigNumber.from(10),
                    goldForTime: eth0, // Auto
                },
                reward: {
                    ...reward,
                    food: eth100,
                },
                image100: "farming100.webp",
                name: "Farming",
                description: "Produces food",
            },
            {
                eventActionId: EventActionEnum.Burn,
                cost: {
                    ...cost,
                    manPower: eth1,
                    time: BigNumber.from(0), // Instant execution
                    goldForTime: eth0, // Auto
                    food: eth0, // Auto calculated from (time * manPower) = zero
                },
                reward: {
                    ...zeroCost, // No reward
                },
                image100: "HouseConstruction100.webp",
                name: "Burn",
                description: "Set the farms on fire to destory them. No resources are gained.",
            }
        ],
    },
    {
        typeId: AssetTypeEnum.Sawmill,
        name: "Sawmill",
        description: "Greatly increases the production of wood",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: AssetTypeEnum.Blacksmith,
        name: "Blacksmith",
        description: "Greatly increases the production of iron",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: AssetTypeEnum.Quarry,
        name: "Quarry",
        description: "Greatly increases the production of rock",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
];


export function getAssetActionData(): any {

    let assetActions = new Array<any>();
    assets.forEach((asset) => {
        if (!asset.actions) return;

        let actions = asset?.actions?.map((action) => {
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

    let result = assets.map(asset => {
        let r = { ...asset };
        delete r.actions;
        return r;
    });

    return result;
}

export function getAsset(typeId: any): any {
    return assets?.find((a: any) => a.typeId === typeId);
}



export function getAssetAction(asset: any, actionId: any): any {
    if (!asset || !actionId) return;
    return asset?.actions?.find((a: any) => a.actionId === actionId);
}


export function getContracts(chainId: any, signer: any) {
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

export const baseCostSettings = {
    "1337": {
        provinceLimit: BigNumber.from(9),
        baseProvinceCost: eth9,
        baseCommodityReward: eth100,
        baseGoldCost: eth1,
        baseUnit: eth1,
        timeBaseCost: BigNumber.from(0),
        goldForTimeBaseCost: eth1,
        foodBaseCost: eth1,
        woodBaseCost: eth1,
        rockBaseCost: eth1,
        ironBaseCost: eth1,
        vassalTribute: eth1
    }
}