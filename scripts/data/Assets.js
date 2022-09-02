const { BigNumber } = require("ethers");
const { parseUnits } = require("ethers/lib/utils.js");

//const { ethers } = require("hardhat");
//const { AssetType, EventState, EventAction } = require("../libraries/ContractTypes.js");

const eth0_1 = parseUnits("0.1", "ether");
const eth0_5 = parseUnits("0.5", "ether");
const eth0 = BigNumber.from(0);
const eth1 = parseUnits("1.0", "ether");
const eth4 = parseUnits("4.0", "ether");
const eth5 = parseUnits("5.0", "ether");
const eth8 = parseUnits("4.0", "ether");
const eth10 = parseUnits("10.0", "ether");
const eth50 = parseUnits("50.0", "ether"); // 100 mill eth
const eth100 = parseUnits("100.0", "ether"); // 100 mill eth


const EventState = {
    Active: 0,
    PaidFor: 1,
    Completed: 2,
    Cancelled: 3
}

const EventAction = {
    Build: 0,
    Dismantle: 1,
    Produce: 2,
    Burn: 3
}

const AssetType = {
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

const zeroCost = {
    manPower: eth0,
    manPowerAttrition: eth0,
    attrition: eth0,
    penalty: eth0,
    time: eth0,
    goldForTime: eth0,
    food: eth0,
    wood: eth0,
    rock: eth0,
    iron: eth0
}

const cost = {
    ...zeroCost,
    manPower: BigNumber.from(10),
    attrition: eth0_1,
    penalty: eth0_5,
    time: BigNumber.from(60 * 60 * 4), // 4 hours
    goldForTime: eth1,
}

const reward = {
    ...zeroCost,
}


const assets = [
    {
        typeId: AssetType.Farm,
        name: "Farm",
        description: "Greatly increases the production of food",
        requiredUserLevel: eth0,
        requiredAssets: [],
        actions: [
            {
                eventActionId: EventAction.Build,
                cost: {
                    ...cost,
                    manPower: 10,
                    wood: eth50, // 50 wood
                },
                reward: {
                    ...reward,
                    food: eth100, // 100 food
                },
                image100: "HouseConstruction100.webp",
                name: "Build",
                description: "Build a farm",
            },
            {
                eventActionId: EventAction.Dismantle,
                cost: {
                    ...cost,
                    manPower: 2,
                    time: 60 * 60, // 5 minutes
                    goldForTime: eth0, // Auto calculated from (time * manPower)
                    food: eth0 // Auto calculated from (time * manPower)
                },
                reward: {
                    ...reward,
                    wood: eth10, // 10 wood
                }
            },
            {
                eventActionId: EventAction.Produce,
                cost: {
                    ...cost,
                    manPower: 10,
                    time: 60 * 60 * 4, // 4 hours
                    goldForTime: eth0, // Auto
                },
                reward: {
                    ...reward,
                    food: eth100,
                }
            },
            {
                eventActionId: EventAction.Burn,
                cost: {
                    ...cost,
                    manPower: 1,
                    time: eth0, // Instant execution
                    goldForTime: eth0, // Auto
                    food: eth0 // Auto calculated from (time * manPower) = zero
                },
                reward: {
                    ...zeroCost, // No reward
                }
            }
        ]
    },
    {
        typeId: AssetType.Sawmill,
        name: "Sawmill",
        description: "Greatly increases the production of wood",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: AssetType.Blacksmith,
        name: "Blacksmith",
        description: "Greatly increases the production of iron",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: AssetType.Quarry,
        name: "Quarry",
        description: "Greatly increases the production of rock",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },

];


function getAssetActionData() {

    let assetActions = [];
    assets.forEach((asset) => {
        if (!asset.actions) return;

        let actions = asset?.actions?.map((action) => {
            let r = {
                assetTypeId: asset.typeId,
                ...action
            }
            delete r.name;
            delete r.description;
            delete r.image100;

            return r;
        });

        if (actions && actions.length > 0)
            assetActions = [...assetActions, ...actions];
    });

    //let assetActions = [].concat(...arr);


    return assetActions;
}

function getAssetData() {

    let result = assets.map(asset => {
        let r = { ...asset };
        delete r.actions;
        return r;
    });

    return result;
}

function getAsset(typeId) {
    return assets?.find((a) => a.typeId === typeId);
}

function getAssetAction(asset, actionId) {
    if (!asset || !actionId) return;
    return asset?.actions?.find((a) => a.actionId === actionId);
}


module.exports = {
    AssetType,
    EventState,
    EventAction,
    zeroCost,
    cost,
    reward,
    assets,
    getAssetData,
    getAssetActionData,
    getAsset,
    getAssetAction,
}
