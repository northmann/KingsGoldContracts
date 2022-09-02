"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.baseCostSettings = exports.getContracts = exports.getAssetAction = exports.getAsset = exports.getAssetData = exports.getAssetActionData = exports.assets = exports.reward = exports.cost = exports.zeroCost = exports.AssetTypeEnum = exports.EventActionEnum = exports.EventState = void 0;
const ethers_1 = require("ethers");
const utils_1 = require("ethers/lib/utils");
const contractAddresses_json_1 = __importDefault(require("./contractAddresses.json"));
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
exports.zeroCost = {
    manPower: ethers_1.BigNumber.from(0),
    manPowerAttrition: eth0,
    attrition: eth0,
    penalty: eth0,
    time: ethers_1.BigNumber.from(0),
    goldForTime: eth0,
    food: eth0,
    wood: eth0,
    rock: eth0,
    iron: eth0
};
exports.cost = Object.assign(Object.assign({}, exports.zeroCost), { manPower: ethers_1.BigNumber.from(10), attrition: eth0_1, penalty: eth0_5, time: ethers_1.BigNumber.from(60 * 60 * 4), goldForTime: eth1 });
exports.reward = Object.assign({}, exports.zeroCost);
exports.assets = [
    {
        typeId: exports.AssetTypeEnum.Farm,
        name: "Farm",
        description: "Greatly increases the production of food",
        requiredUserLevel: eth0,
        requiredAssets: [],
        image100: "Farm100.png",
        actions: [
            {
                actionId: exports.EventActionEnum.Build,
                cost: Object.assign(Object.assign({}, exports.cost), { wood: eth50 }),
                reward: Object.assign(Object.assign({}, exports.reward), { food: eth100 }),
                image100: "HouseConstruction100.webp",
                name: "Build",
                description: "Build a farm",
            },
            {
                actionId: exports.EventActionEnum.Dismantle,
                cost: Object.assign(Object.assign({}, exports.cost), { manPower: ethers_1.BigNumber.from(2) }),
                reward: Object.assign(Object.assign({}, exports.reward), { wood: eth10 }),
                image100: "HouseConstruction100.webp",
                name: "Dismante",
                description: "Breakdown farms to gain some wood",
            },
            {
                actionId: exports.EventActionEnum.Produce,
                cost: Object.assign(Object.assign({}, exports.cost), { manPower: ethers_1.BigNumber.from(10), goldForTime: eth0 }),
                reward: Object.assign(Object.assign({}, exports.reward), { food: eth100 }),
                image100: "farming100.webp",
                name: "Farming",
                description: "Produces food",
            },
            {
                eventActionId: exports.EventActionEnum.Burn,
                cost: Object.assign(Object.assign({}, exports.cost), { manPower: eth1, time: ethers_1.BigNumber.from(0), goldForTime: eth0, food: eth0 }),
                reward: Object.assign({}, exports.zeroCost),
                image100: "HouseConstruction100.webp",
                name: "Burn",
                description: "Set the farms on fire to destory them. No resources are gained.",
            }
        ],
    },
    {
        typeId: exports.AssetTypeEnum.Sawmill,
        name: "Sawmill",
        description: "Greatly increases the production of wood",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: exports.AssetTypeEnum.Blacksmith,
        name: "Blacksmith",
        description: "Greatly increases the production of iron",
        requiredUserLevel: eth0,
        requiredAssets: [],
    },
    {
        typeId: exports.AssetTypeEnum.Quarry,
        name: "Quarry",
        description: "Greatly increases the production of rock",
        requiredUserLevel: eth0,
        requiredAssets: [],
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
    let result = exports.assets.map(asset => {
        let r = Object.assign({}, asset);
        delete r.actions;
        return r;
    });
    return result;
}
exports.getAssetData = getAssetData;
function getAsset(typeId) {
    return exports.assets === null || exports.assets === void 0 ? void 0 : exports.assets.find((a) => a.typeId === typeId);
}
exports.getAsset = getAsset;
function getAssetAction(asset, actionId) {
    var _a;
    if (!asset || !actionId)
        return;
    return (_a = asset === null || asset === void 0 ? void 0 : asset.actions) === null || _a === void 0 ? void 0 : _a.find((a) => a.actionId === actionId);
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
exports.baseCostSettings = {
    "1337": {
        provinceLimit: ethers_1.BigNumber.from(9),
        baseProvinceCost: eth9,
        baseCommodityReward: eth100,
        baseGoldCost: eth1,
        baseUnit: eth1,
        timeBaseCost: ethers_1.BigNumber.from(0),
        goldForTimeBaseCost: eth1,
        foodBaseCost: eth1,
        woodBaseCost: eth1,
        rockBaseCost: eth1,
        ironBaseCost: eth1,
        vassalTribute: eth1
    }
};
//# sourceMappingURL=assets.js.map