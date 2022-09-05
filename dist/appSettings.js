"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAppSettings = exports.appSettings = void 0;
const ethers_1 = require("ethers");
const constants_1 = require("./constants");
exports.appSettings = {
    generic: {
        provinceLimit: ethers_1.BigNumber.from(9),
        baseProvinceCost: constants_1.eth9,
        baseProvinceSpend: constants_1.eth1,
        baseProvinceRequired: constants_1.eth10,
        baseCommodityReward: constants_1.eth100,
        baseGoldCost: constants_1.eth1,
        baseUnit: constants_1.eth1,
        timeBaseCost: ethers_1.BigNumber.from(0),
        goldForTimeBaseCost: constants_1.eth1,
        foodBaseCost: constants_1.eth1,
        woodBaseCost: constants_1.eth1,
        rockBaseCost: constants_1.eth1,
        ironBaseCost: constants_1.eth1,
        vassalTribute: constants_1.eth0_5, // 50% of the vassal's gains are given to the king
    },
    1337: { // Localhost
    }
};
function getAppSettings(chainId) {
    return Object.assign(Object.assign({}, exports.appSettings.generic), exports.appSettings[chainId]);
}
exports.getAppSettings = getAppSettings;
//# sourceMappingURL=appSettings.js.map