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
    food: constants_1.eth1,
    amount: ethers_1.BigNumber.from(1), // 1 structure
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
const buildAction = {
    eventActionId: constants_1.EventActionEnum.Build,
    method: "buildStructure(uint256)",
    cost: {
        ...exports.cost,
    },
    reward: {
        ...exports.reward,
    },
    image100: "HouseConstruction100.webp",
    title: "Build",
    description: "Build a structure",
    executeTitle: "Build"
};
const produceAction = {
    eventActionId: constants_1.EventActionEnum.Produce,
    method: "produceStructure(uint256)",
    cost: {
        ...exports.cost,
    },
    reward: {
        ...exports.reward,
    },
    image100: "HouseConstruction100.webp",
    title: "Produce",
    description: "Produce a resource",
    executeTitle: "Produce"
};
const dismantleAction = {
    eventActionId: constants_1.EventActionEnum.Dismantle,
    method: "dismantleStructure(uint256)",
    cost: {
        ...exports.cost,
    },
    reward: {
        ...exports.reward,
    },
    image100: "HouseConstruction100.webp",
    title: "Dismantle",
    description: "Dismantle a resource",
    executeTitle: "Dismantle"
};
const burnAction = {
    eventActionId: constants_1.EventActionEnum.Burn,
    method: "burnStructure(uint256)",
    cost: {
        ...exports.cost,
    },
    reward: {
        ...exports.reward,
    },
    image100: "HouseConstruction100.webp",
    title: "Burn",
    description: "Burn a resource",
    executeTitle: "Burn"
};
exports.assets = {
    [constants_1.AssetTypeEnum.None]: {
        typeId: constants_1.AssetTypeEnum.None,
        productId: constants_1.AssetProductEnum.None,
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
    },
    [constants_1.AssetTypeEnum.Farm]: {
        typeId: constants_1.AssetTypeEnum.Farm,
        productId: constants_1.AssetProductEnum.Structure,
        title: "Farm",
        description: "Produces food",
        image100: "Farm100.png",
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
        actions: {
            [constants_1.EventActionEnum.Build]: {
                ...buildAction,
                cost: {
                    ...exports.cost,
                    wood: constants_1.eth50,
                    food: constants_1.eth0,
                    amount: ethers_1.BigNumber.from(0),
                },
                reward: {
                    ...exports.reward,
                    amount: ethers_1.BigNumber.from(1), // 1 farm
                },
                image100: "HouseConstruction100.webp",
                description: "Build a farm",
            },
            [constants_1.EventActionEnum.Dismantle]: {
                ...dismantleAction,
                ...dismantleCost,
                description: "Breakdown farms to gain some wood",
            },
            [constants_1.EventActionEnum.Produce]: {
                ...produceAction,
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
                    amount: ethers_1.BigNumber.from(1), // return available structure
                },
                image100: "farming100.webp",
                title: "Farming",
                description: "Produces food",
            },
            [constants_1.EventActionEnum.Burn]: {
                ...burnAction,
                ...burnCost,
                description: "Set the farms on fire to destory them. No resources are gained.",
            }
        }
    },
    [constants_1.AssetTypeEnum.Sawmill]: {
        typeId: constants_1.AssetTypeEnum.Sawmill,
        productId: constants_1.AssetProductEnum.Structure,
        title: "Sawmill",
        description: "Greatly increases the production of wood",
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
        image100: "sawmillE100.webp",
        actions: {
            [constants_1.EventActionEnum.Build]: {
                ...buildAction,
                cost: {
                    ...exports.cost,
                    food: constants_1.eth50,
                    amount: ethers_1.BigNumber.from(0),
                },
                reward: {
                    ...exports.reward,
                    amount: ethers_1.BigNumber.from(1), // 1 blacksmith
                },
                image100: "sawmillE100.webp",
                description: "Build a sawmill",
            },
            [constants_1.EventActionEnum.Dismantle]: {
                ...dismantleAction,
                ...dismantleCost,
                reward: {
                    ...exports.reward,
                    wood: constants_1.eth5,
                },
                description: "Breakdown sawmill to gain some wood",
            },
            [constants_1.EventActionEnum.Produce]: {
                ...produceAction,
                cost: {
                    ...exports.cost,
                    manPower: ethers_1.BigNumber.from(1),
                    time: ethers_1.BigNumber.from(60 * 60 * 4), // 4 hours,
                },
                reward: {
                    ...exports.reward,
                    wood: constants_1.eth50,
                    amount: ethers_1.BigNumber.from(1), // return available structure
                },
                image100: "sawmillE100.webp",
                title: "Produce",
                description: "Produces fine wood",
                executeTitle: "Produce",
            },
            [constants_1.EventActionEnum.Burn]: {
                ...burnAction,
                ...burnCost,
                description: "Set the sawmill on fire to destory it. No resources are gained in the process.",
            }
        },
    },
    [constants_1.AssetTypeEnum.Blacksmith]: {
        typeId: constants_1.AssetTypeEnum.Blacksmith,
        productId: constants_1.AssetProductEnum.Structure,
        title: "Blacksmith",
        description: "Produces iron",
        image100: "Blacksmith100.webp",
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
        actions: {
            [constants_1.EventActionEnum.Build]: {
                ...buildAction,
                cost: {
                    ...exports.cost,
                    wood: constants_1.eth50,
                    amount: ethers_1.BigNumber.from(0),
                },
                reward: {
                    ...exports.reward,
                    amount: ethers_1.BigNumber.from(1), // 1 blacksmith
                },
                image100: "HouseConstruction100.webp",
                description: "Build a blacksmith",
            },
            [constants_1.EventActionEnum.Dismantle]: {
                ...dismantleAction,
                ...dismantleCost,
                reward: {
                    ...exports.reward,
                    wood: constants_1.eth5,
                    iron: constants_1.eth5,
                },
                description: "Breakdown blacksmith to gain some wood and iron",
            },
            [constants_1.EventActionEnum.Produce]: {
                ...produceAction,
                cost: {
                    ...exports.cost,
                    manPower: ethers_1.BigNumber.from(1),
                    time: ethers_1.BigNumber.from(60 * 60 * 4), // 4 hours,
                },
                reward: {
                    ...exports.reward,
                    iron: constants_1.eth50,
                    amount: ethers_1.BigNumber.from(1), // return available structure
                },
                image100: "Blacksmith100.webp",
                title: "Molding",
                description: "Produces iron",
                executeTitle: "Mold",
            },
            [constants_1.EventActionEnum.Burn]: {
                ...burnAction,
                ...burnCost,
                description: "Set the blacksmith on fire to destory it. No resources are gained in the process.",
            }
        },
    },
    [constants_1.AssetTypeEnum.Quarry]: {
        typeId: constants_1.AssetTypeEnum.Quarry,
        productId: constants_1.AssetProductEnum.Structure,
        title: "Quarry",
        description: "Greatly increases the production of rock",
        requiredUserLevel: constants_1.eth0,
        requiredAssets: [],
    },
    [constants_1.AssetTypeEnum.Barrack]: {
        typeId: constants_1.AssetTypeEnum.Barrack,
        productId: constants_1.AssetProductEnum.Structure,
        title: "Barrack",
        description: "Produces soldiers",
        requiredUserLevel: ethers_1.BigNumber.from(100),
        requiredAssets: [constants_1.AssetTypeEnum.Farm, constants_1.AssetTypeEnum.Blacksmith],
        image100: "HouseConstruction100.webp",
        actions: {
            [constants_1.EventActionEnum.Build]: {
                ...buildAction,
                cost: {
                    ...exports.cost,
                    manPower: ethers_1.BigNumber.from(2),
                    time: ethers_1.BigNumber.from(60 * 60 * 8),
                    wood: constants_1.eth100,
                    iron: constants_1.eth1,
                    food: constants_1.eth1.mul(8 * 2),
                    amount: ethers_1.BigNumber.from(0),
                },
                reward: {
                    ...exports.reward,
                    amount: ethers_1.BigNumber.from(1), // 1 barrack
                },
                image100: "HouseConstruction100.webp",
                description: "Build a barrack",
            },
            [constants_1.EventActionEnum.Dismantle]: {
                ...dismantleAction,
                ...dismantleCost,
                reward: {
                    ...exports.reward,
                    wood: constants_1.eth5,
                    iron: constants_1.eth5,
                },
                description: "Breakdown barrack to gain some wood and iron",
            },
            [constants_1.EventActionEnum.Produce]: {
                ...produceAction,
                method: "produceSoldier(uint256)",
                cost: {
                    ...exports.cost,
                    manPower: ethers_1.BigNumber.from(1),
                    time: ethers_1.BigNumber.from(60 * 60 * 4), // 4 hours
                },
                reward: {
                    ...exports.reward,
                    amount: ethers_1.BigNumber.from(1), // 1 soldier
                },
                image100: "HouseConstruction100.webp",
                title: "Recruit",
                description: "Recruit soldiers",
                executeTitle: "Recruit",
            },
            [constants_1.EventActionEnum.Burn]: {
                ...burnAction,
                ...burnCost,
                description: "Set the barrack on fire to destory it. No resources are gained in the process.",
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
                reward: action.reward,
                method: action.method,
            };
            return r;
        });
        if (actions && actions.length > 0)
            assetActions = [...assetActions, ...actions];
    });
    let result = assetActions;
    console.log("assetActions", result);
    return result;
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
function getAssetsByGroup(productId) {
    let assetData = Object.keys(exports.assets).filter((key) => exports.assets[key].productId === productId).map((key) => exports.assets[key]);
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