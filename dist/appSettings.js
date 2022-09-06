"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAppSettings = exports.appSettings = void 0;
const ethers_1 = require("ethers");
const constants_1 = require("./constants");
const contractAddresses_json_1 = __importDefault(require("./contractAddresses.json"));
exports.appSettings = {
    generic: {
        baseGoldCost: constants_1.eth1,
        baseUnit: constants_1.eth1,
        provinceLimit: ethers_1.BigNumber.from(9),
        provinceCost: constants_1.eth10,
        provinceDeposit: constants_1.eth90,
        provinceSpend: constants_1.eth1,
        //baseProvinceRequired: eth10, // The required amount of gold to buy a province = provinceCost + provinceDeposit + provinceSpend
        baseCommodityReward: constants_1.eth1,
        timeBaseCost: ethers_1.BigNumber.from(60 * 60),
        goldForTimeBaseCost: constants_1.eth1,
        provinceFoodInit: constants_1.eth10,
        provinceWoodInit: constants_1.eth100,
        provinceRockInit: constants_1.eth0,
        provinceIronInit: constants_1.eth0,
        vassalTribute: constants_1.eth0_5, // 50% of the vassal's gains are given to the king
    },
    1337: {
        diamond: contractAddresses_json_1.default["Diamond"],
        gold: contractAddresses_json_1.default["KingsGold"],
        food: contractAddresses_json_1.default["Food"],
        wood: contractAddresses_json_1.default["Wood"],
        rock: contractAddresses_json_1.default["Rock"],
        iron: contractAddresses_json_1.default["Iron"],
        provinceNFT: contractAddresses_json_1.default["ProvinceNFT"],
    }
};
function getAppSettings(chainId) {
    return Object.assign(Object.assign({}, exports.appSettings.generic), exports.appSettings[chainId]);
}
exports.getAppSettings = getAppSettings;
//# sourceMappingURL=appSettings.js.map