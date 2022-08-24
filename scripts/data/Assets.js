const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const { AssetType, EventState, EventAction } = require("../libraries/ContractTypes.js");

const eth0_1 = ethers.utils.parseUnits("0.1", "ether");
const eth0_5 = ethers.utils.parseUnits("0.5", "ether");
const eth0 = BigNumber.from(0);
const eth1 = ethers.utils.parseUnits("1.0", "ether");
const eth4 = ethers.utils.parseUnits("4.0", "ether");
const eth5 = ethers.utils.parseUnits("5.0", "ether");
const eth8 = ethers.utils.parseUnits("4.0", "ether");
const eth10 = ethers.utils.parseUnits("10.0", "ether");
const eth50 = ethers.utils.parseUnits("50.0", "ether"); // 100 mill eth
const eth100 = ethers.utils.parseUnits("100.0", "ether"); // 100 mill eth


// function ResourceFactor(cost) {
//     return {
//         manPower: cost.manPower || eth10,
//         manPowerAttrition: 0,
//         attrition: cost.attrition || eth0_1,
//         penalty: cost.penalty || eth0_5,
//         time: cost.time || eth4,
//         goldForTime: cost.goldForTime || eth1,
//         food: cost.food || eth0,
//         wood: cost.wood || eth0,
//         rock: cost.rock || eth0,
//         iron: cost.iron || eth0,
//     }
// }

// function AssetAction(item) {
//     item.cost = ResourceFactor(item.cost);
//     item.reward = ResourceFactor(item.reward);
//     return item;
// }

const cost = {
        manPower: eth10,
        manPowerAttrition: 0,
        attrition: eth0_1,
        penalty: eth0_5,
        time: eth4,
        goldForTime: eth1,
        food: eth0,
        wood: eth0,
        rock: eth0,
        iron:  eth0,
    }

const reward = cost;


const assets = [
    {
        typeId: AssetType.Farm,
        name: "Farm",
        description: "Greatly increases the production of food",
        requiredUserLevel: eth0,
        requiredAssets: [],
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

const assetActions = [
    {
        assetTypeId: AssetType.Farm,
        actionId: EventAction.Build,
        cost: {
            ...cost,
            manPower: 10,
            wood: eth50,
        },
        reward: {
            ...reward,
            food: eth100,
        }
    },
    {
        assetTypeId: AssetType.Farm,
        actionId: EventAction.Dismantle,
        cost: {
            ...cost,
            manPower: 1,
            food: eth5
        },
        reward: {
            ...reward,
            wood: eth50,
        }
    },
    {
        assetTypeId: AssetType.Farm,
        actionId: EventAction.Produce,
        cost: {
            ...cost,
            manPower: 10,
            goldForTime: eth1,
            time: eth4,
        },
        reward: {
            ...reward,
            food: eth100,
        }
    }
]

function getAssetActionData() {
    return assetActions;
}

function getAssetData() {
    let asset = {
        typeId: AssetType.Farm,
        name: "Farm",
        description: "Greatly increases the production of food",
        requiredUserLevel: eth0,
        requiredAssets: [],
    }
    return [asset];
}


module.exports = {
    getAssetData,
    getAssetActionData,

}
