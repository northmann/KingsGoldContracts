"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAppSettings = exports.getContracts = exports.getAssetAction = exports.getAsset = exports.getAssetData = exports.getAssetActionData = exports.assets = exports.reward = exports.cost = exports.zeroCost = exports.AssetGroupEnum = exports.AssetTypeEnum = exports.EventActionEnum = exports.EventState = void 0;
const ethers_1 = require("ethers");
const utils_1 = require("ethers/lib/utils");
const contractAddresses_json_1 = __importDefault(require("./contractAddresses.json"));
const appSettings_1 = require("./appSettings");
const Diamond_json_1 = __importDefault(require("./abi/Diamond.json"));
const KingsGold_json_1 = __importDefault(require("./abi/KingsGold.json"));
const Wood_json_1 = __importDefault(require("./abi/Wood.json"));
const Rock_json_1 = __importDefault(require("./abi/Rock.json"));
const Iron_json_1 = __importDefault(require("./abi/Iron.json"));
const Food_json_1 = __importDefault(require("./abi/Food.json"));
const UserFacet_json_1 = __importDefault(require("./abi/UserFacet.json"));
const TreasuryFacet_json_1 = __importDefault(require("./abi/TreasuryFacet.json"));
const ProvinceFacet_json_1 = __importDefault(require("./abi/ProvinceFacet.json"));
const eth0_1 = (0, utils_1.parseUnits)("0.1", "ether");
const eth0_5 = (0, utils_1.parseUnits)("0.5", "ether");
const eth0 = ethers_1.BigNumber.from(0);
const eth1 = (0, utils_1.parseUnits)("1.0", "ether");
const eth2 = (0, utils_1.parseUnits)("2.0", "ether");
const eth4 = (0, utils_1.parseUnits)("4.0", "ether");
const eth5 = (0, utils_1.parseUnits)("5.0", "ether");
const eth8 = (0, utils_1.parseUnits)("4.0", "ether");
const eth9 = (0, utils_1.parseUnits)("1.0", "ether");
const eth10 = (0, utils_1.parseUnits)("10.0", "ether");
const eth50 = (0, utils_1.parseUnits)("50.0", "ether"); // 100 mill eth
const eth100 = (0, utils_1.parseUnits)("100.0", "ether"); // 100 mill eth
exports.EventState = {
    Active: 0,
    PaidFor: 1,
    Completed: 2,
    Cancelled: 3
};
exports.EventActionEnum = {
    Build: 0,
    Dismantle: 1,
    Produce: 2,
    Burn: 3
};
exports.AssetTypeEnum = {
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
};
exports.AssetGroupEnum = {
    None: 0,
    Structure: 1,
    Population: 2,
    Commodity: 3,
    Artifact: 4
};
exports.zeroCost = {
    manPower: ethers_1.BigNumber.from(0),
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
};
exports.cost = Object.assign(Object.assign({}, exports.zeroCost), { manPower: ethers_1.BigNumber.from(1), attrition: eth0_1, penalty: eth0_5 });
exports.reward = Object.assign({}, exports.zeroCost);
const dismantleCost = {
    eventActionId: exports.EventActionEnum.Dismantle,
    cost: Object.assign(Object.assign({}, exports.cost), { manPower: ethers_1.BigNumber.from(2) }),
    reward: Object.assign(Object.assign({}, exports.reward), { wood: eth10 }),
    image100: "HouseConstruction100.webp",
    title: "Dismante",
    description: "Breakdown structure to gain some wood",
    executeTitle: "Dismantle",
};
const burnCost = {
    eventActionId: exports.EventActionEnum.Burn,
    cost: Object.assign(Object.assign({}, exports.cost), { manPower: ethers_1.BigNumber.from(1), time: ethers_1.BigNumber.from(60), food: eth0 }),
    reward: Object.assign({}, exports.zeroCost),
    image100: "HouseConstruction100.webp",
    title: "Burn",
    description: "Set the structure on fire to destory it. No resources are gained in the process.",
    executeTitle: "Burn",
};
exports.assets = [
    {
        typeId: exports.AssetTypeEnum.None,
        groupId: exports.AssetGroupEnum.None,
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: exports.AssetTypeEnum.Farm,
        groupId: exports.AssetGroupEnum.Structure,
        title: "Farm",
        description: "Produces food",
        requiredUserLevel: eth0,
        requiredAssets: [],
        image100: "Farm100.png",
        actions: [
            {
                eventActionId: exports.EventActionEnum.Build,
                cost: Object.assign(Object.assign({}, exports.cost), { wood: eth50 }),
                reward: Object.assign(Object.assign({}, exports.reward), { amount: ethers_1.BigNumber.from(1) }),
                image100: "HouseConstruction100.webp",
                title: "Build",
                description: "Build a farm",
            },
            Object.assign(Object.assign({}, dismantleCost), { description: "Breakdown farms to gain some wood" }),
            {
                eventActionId: exports.EventActionEnum.Produce,
                cost: Object.assign(Object.assign({}, exports.cost), { manPower: ethers_1.BigNumber.from(1), time: ethers_1.BigNumber.from(60 * 60 * 4), 
                    // goldForTime - Auto calculated from (1 manPower * 4 hours) = 4 gold 
                    food: eth0 }),
                reward: Object.assign(Object.assign({}, exports.reward), { food: eth50 }),
                image100: "farming100.webp",
                title: "Farming",
                description: "Produces food 4",
            },
            Object.assign(Object.assign({}, burnCost), { description: "Set the farms on fire to destory them. No resources are gained." })
        ],
    },
    {
        typeId: exports.AssetTypeEnum.Sawmill,
        groupId: exports.AssetGroupEnum.Structure,
        title: "Sawmill",
        description: "Greatly increases the production of wood",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: exports.AssetTypeEnum.Blacksmith,
        groupId: exports.AssetGroupEnum.Structure,
        title: "Blacksmith",
        description: "Produces iron",
        requiredUserLevel: eth0,
        requiredAssets: [],
        image100: "Blacksmith100.webp",
        actions: [
            {
                eventActionId: exports.EventActionEnum.Build,
                cost: Object.assign(Object.assign({}, exports.cost), { wood: eth50 }),
                reward: Object.assign(Object.assign({}, exports.reward), { amount: ethers_1.BigNumber.from(1) }),
                image100: "HouseConstruction100.webp",
                title: "Build",
                description: "Build a blacksmith",
            },
            Object.assign(Object.assign({}, dismantleCost), { reward: Object.assign(Object.assign({}, exports.reward), { wood: eth5, iron: eth5 }), description: "Breakdown blacksmith to gain some wood and iron" }),
            {
                eventActionId: exports.EventActionEnum.Produce,
                cost: Object.assign(Object.assign({}, exports.cost), { manPower: ethers_1.BigNumber.from(1), time: ethers_1.BigNumber.from(60 * 60 * 4) }),
                reward: Object.assign(Object.assign({}, exports.reward), { iron: eth50 }),
                image100: "Blacksmith100.webp",
                title: "Molding",
                description: "Produces iron",
                executeTitle: "Mold",
            },
            Object.assign(Object.assign({}, burnCost), { description: "Set the blacksmith on fire to destory it. No resources are gained in the process." })
        ],
    },
    {
        typeId: exports.AssetTypeEnum.Quarry,
        groupId: exports.AssetGroupEnum.Structure,
        title: "Quarry",
        description: "Greatly increases the production of rock",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: exports.AssetTypeEnum.Barrack,
        groupId: exports.AssetGroupEnum.Structure,
        title: "Barrack",
        description: "Produces soldiers",
        requiredUserLevel: ethers_1.BigNumber.from(100),
        requiredAssets: [exports.AssetTypeEnum.Farm, exports.AssetTypeEnum.Blacksmith],
    },
];
function getAssetActionData() {
    let assetActions = new Array();
    exports.assets.forEach((asset) => {
        var _a;
        if (!asset.actions)
            return;
        let actions = (_a = asset === null || asset === void 0 ? void 0 : asset.actions) === null || _a === void 0 ? void 0 : _a.map((action) => {
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
    //let assetActions = [].concat(...arr);
    return assetActions;
}
exports.getAssetActionData = getAssetActionData;
function getAssetData() {
    let result = exports.assets.map((asset) => {
        let r = Object.assign({}, asset);
        delete r.actions;
        delete r.title;
        delete r.description;
        delete r.image100;
        return r;
    });
    return result;
}
exports.getAssetData = getAssetData;
function getAsset(typeId) {
    return exports.assets === null || exports.assets === void 0 ? void 0 : exports.assets.find((a) => a.typeId === typeId);
}
exports.getAsset = getAsset;
function getAssetAction(asset, eventActionId) {
    var _a;
    if (!asset || !eventActionId)
        return;
    return (_a = asset === null || asset === void 0 ? void 0 : asset.actions) === null || _a === void 0 ? void 0 : _a.find((a) => a.eventActionId === eventActionId);
}
exports.getAssetAction = getAssetAction;
function getContracts(chainId, signer) {
    let result = {};
    result.diamond = new ethers_1.Contract(contractAddresses_json_1.default["Diamond"], Diamond_json_1.default, signer);
    result.kingsGold = new ethers_1.Contract(contractAddresses_json_1.default["KingsGold"], KingsGold_json_1.default, signer);
    result.wood = new ethers_1.Contract(contractAddresses_json_1.default["Wood"], Wood_json_1.default, signer);
    result.rock = new ethers_1.Contract(contractAddresses_json_1.default["Rock"], Rock_json_1.default, signer);
    result.iron = new ethers_1.Contract(contractAddresses_json_1.default["Iron"], Iron_json_1.default, signer);
    result.food = new ethers_1.Contract(contractAddresses_json_1.default["Food"], Food_json_1.default, signer);
    result.userFacet = new ethers_1.Contract(contractAddresses_json_1.default["Diamond"], UserFacet_json_1.default, signer);
    result.treasuryFacet = new ethers_1.Contract(contractAddresses_json_1.default["Diamond"], TreasuryFacet_json_1.default, signer);
    result.provinceFacet = new ethers_1.Contract(contractAddresses_json_1.default["Diamond"], ProvinceFacet_json_1.default, signer);
    return result;
}
exports.getContracts = getContracts;
function getAppSettings(chainId) {
    return Object.assign(Object.assign({}, appSettings_1.appSettings.generic), appSettings_1.appSettings[chainId]);
}
exports.getAppSettings = getAppSettings;
//# sourceMappingURL=assets.js.map