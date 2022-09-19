"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAssetAction = exports.getAssetsByGroup = exports.getAsset = exports.getAssetData = exports.getAssetActionData = exports.assets = exports.reward = exports.cost = exports.zeroCost = void 0;
const ethers_1 = require("ethers");
const constants_1 = require("./constants");
exports.zeroCost = {
    manPower: ethers_1.BigNumber.from(0),
    manPowerAttrition: constants_1.eth0,
    attrition: constants_1.eth0,
    penalty: constants_1.eth0,
    time: constants_1.eth0,
    goldForTime: constants_1.eth0,
    food: constants_1.eth0,
    wood: constants_1.eth0,
    rock: constants_1.eth0,
    iron: constants_1.eth0,
    gold: constants_1.eth0,
    amount: constants_1.eth0, // used for building and burning
};
exports.cost = {
    ...exports.zeroCost,
    manPower: ethers_1.BigNumber.from(1),
    attrition: constants_1.eth0_1,
    penalty: constants_1.eth0_5,
    // time: BigNumber.from(60 * 60 * 1), // 1 hours standard
    // goldForTime is calculated in the contract
    food: constants_1.eth1, // It cost 1 food per one manPower per hour
};
exports.reward = {
    ...exports.zeroCost,
};
const dismantleCost = {
    eventActionId: constants_1.EventActionEnum.Dismantle,
    cost: {
        ...exports.cost,
        manPower: ethers_1.BigNumber.from(2),
    },
    reward: {
        ...exports.reward,
        wood: constants_1.eth10,
    },
    image100: "HouseConstruction100.webp",
    title: "Dismante",
    description: "Breakdown structure to gain some wood",
    executeTitle: "Dismantle",
};
const burnCost = {
    eventActionId: constants_1.EventActionEnum.Burn,
    cost: {
        ...exports.cost,
        manPower: ethers_1.BigNumber.from(1),
        time: ethers_1.BigNumber.from(60),
        food: constants_1.eth0, // It cost no food to burn down a farm
    },
    reward: {
        ...exports.zeroCost, // No reward
    },
    image100: "HouseConstruction100.webp",
    title: "Burn",
    description: "Set the structure on fire to destory it. No resources are gained in the process.",
    executeTitle: "Burn",
};
exports.assets = {
    [constants_1.AssetTypeEnum.None]: {
        typeId: constants_1.AssetTypeEnum.None,
        groupId: constants_1.AssetGroupEnum.None,
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
    },
    [constants_1.AssetTypeEnum.Farm]: {
        typeId: constants_1.AssetTypeEnum.Farm,
        groupId: constants_1.AssetGroupEnum.Structure,
        title: "Farm",
        description: "Produces food",
        image100: "Farm100.png",
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
        actions: {
            [constants_1.EventActionEnum.Build]: {
                eventActionId: constants_1.EventActionEnum.Build,
                cost: {
                    ...exports.cost,
                    wood: constants_1.eth50,
                    food: constants_1.eth0,
                },
                reward: {
                    ...exports.reward,
                    amount: ethers_1.BigNumber.from(1), // 1 farm
                },
                image100: "HouseConstruction100.webp",
                title: "Build",
                description: "Build a farm",
            },
            [constants_1.EventActionEnum.Dismantle]: {
                ...dismantleCost,
                description: "Breakdown farms to gain some wood",
            },
            [constants_1.EventActionEnum.Produce]: {
                eventActionId: constants_1.EventActionEnum.Produce,
                cost: {
                    ...exports.cost,
                    manPower: ethers_1.BigNumber.from(1),
                    time: ethers_1.BigNumber.from(60 * 60 * 4),
                    // goldForTime - Auto calculated from (1 manPower * 4 hours) = 4 gold 
                    food: constants_1.eth0, // It cost no food to produce food
                },
                reward: {
                    ...exports.reward,
                    food: constants_1.eth50,
                },
                image100: "farming100.webp",
                title: "Farming",
                description: "Produces food",
            },
            [constants_1.EventActionEnum.Burn]: {
                ...burnCost,
                description: "Set the farms on fire to destory them. No resources are gained.",
            }
        }
    },
    [constants_1.AssetTypeEnum.Sawmill]: {
        typeId: constants_1.AssetTypeEnum.Sawmill,
        groupId: constants_1.AssetGroupEnum.Structure,
        title: "Sawmill",
        description: "Greatly increases the production of wood",
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
    },
    [constants_1.AssetTypeEnum.Blacksmith]: {
        typeId: constants_1.AssetTypeEnum.Blacksmith,
        groupId: constants_1.AssetGroupEnum.Structure,
        title: "Blacksmith",
        description: "Produces iron",
        image100: "Blacksmith100.webp",
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
        actions: {
            [constants_1.EventActionEnum.Build]: {
                eventActionId: constants_1.EventActionEnum.Build,
                cost: {
                    ...exports.cost,
                    wood: constants_1.eth50,
                },
                reward: {
                    ...exports.reward,
                    amount: ethers_1.BigNumber.from(1), // 1 farm
                },
                image100: "HouseConstruction100.webp",
                title: "Build",
                description: "Build a blacksmith",
            },
            [constants_1.EventActionEnum.Dismantle]: {
                ...dismantleCost,
                reward: {
                    ...exports.reward,
                    wood: constants_1.eth5,
                    iron: constants_1.eth5,
                },
                description: "Breakdown blacksmith to gain some wood and iron",
            },
            [constants_1.EventActionEnum.Produce]: {
                eventActionId: constants_1.EventActionEnum.Produce,
                cost: {
                    ...exports.cost,
                    manPower: ethers_1.BigNumber.from(1),
                    time: ethers_1.BigNumber.from(60 * 60 * 4), // 4 hours
                },
                reward: {
                    ...exports.reward,
                    iron: constants_1.eth50,
                },
                image100: "Blacksmith100.webp",
                title: "Molding",
                description: "Produces iron",
                executeTitle: "Mold",
            },
            [constants_1.EventActionEnum.Burn]: {
                ...burnCost,
                description: "Set the blacksmith on fire to destory it. No resources are gained in the process.",
            }
        },
    },
    [constants_1.AssetTypeEnum.Quarry]: {
        typeId: constants_1.AssetTypeEnum.Quarry,
        groupId: constants_1.AssetGroupEnum.Structure,
        title: "Quarry",
        description: "Greatly increases the production of rock",
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
    },
    [constants_1.AssetTypeEnum.Barrack]: {
        typeId: constants_1.AssetTypeEnum.Barrack,
        groupId: constants_1.AssetGroupEnum.Structure,
        title: "Barrack",
        description: "Produces soldiers",
        requiredUserLevel: ethers_1.BigNumber.from(100),
        requiredAssets: [constants_1.AssetTypeEnum.Farm, constants_1.AssetTypeEnum.Blacksmith],
        actions: {
            [constants_1.EventActionEnum.Build]: {
                eventActionId: constants_1.EventActionEnum.Build,
                cost: {
                    ...exports.cost,
                    manPower: ethers_1.BigNumber.from(2),
                    time: ethers_1.BigNumber.from(60 * 60 * 8),
                    wood: constants_1.eth100,
                    iron: constants_1.eth1,
                    food: constants_1.eth1.mul(8 * 2), // 8 hours * 2 manPower
                },
                reward: {
                    ...exports.reward,
                    amount: ethers_1.BigNumber.from(1), // 1 barrack
                },
                image100: "HouseConstruction100.webp",
                title: "Build",
                description: "Build a barrack",
            },
        },
    },
};
function getAssetActionData() {
    let assetActions = new Array();
    Object.keys(exports.assets).forEach((assetKey) => {
        const asset = exports.assets[assetKey];
        if (!asset.actions)
            return;
        let actions = Object.keys(asset.actions).map((key) => {
            let action = asset.actions[key];
            let r = {
                assetTypeId: asset.typeId,
                eventActionId: action.eventActionId,
                cost: action.cost,
                reward: action.reward
            };
            return r;
        });
        if (actions && actions.length > 0)
            assetActions = [...assetActions, ...actions];
    });
    console.log("assetActions", assetActions);
    return assetActions;
}
exports.getAssetActionData = getAssetActionData;
function getAssetData() {
    let assetData = Object.keys(exports.assets).map((key) => {
        let r = { ...exports.assets[key] };
        delete r.actions;
        delete r.title;
        delete r.description;
        delete r.image100;
        return r;
    });
    return assetData;
}
exports.getAssetData = getAssetData;
function getAsset(typeId) {
    return exports.assets === null || exports.assets === void 0 ? void 0 : exports.assets[typeId];
}
exports.getAsset = getAsset;
function getAssetsByGroup(groupId) {
    let assetData = Object.keys(exports.assets).filter((key) => exports.assets[key].groupId === groupId).map((key) => exports.assets[key]);
    return assetData;
}
exports.getAssetsByGroup = getAssetsByGroup;
function getAssetAction(asset, eventActionId) {
    var _a;
    if (!asset || !eventActionId)
        return;
    return (_a = asset === null || asset === void 0 ? void 0 : asset.actions) === null || _a === void 0 ? void 0 : _a[eventActionId];
}
exports.getAssetAction = getAssetAction;
//# sourceMappingURL=assets.js.map