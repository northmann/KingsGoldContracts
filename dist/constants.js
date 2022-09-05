"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AssetGroupEnum = exports.AssetTypeEnum = exports.EventActionEnum = exports.EventState = exports.eth100 = exports.eth50 = exports.eth10 = exports.eth9 = exports.eth8 = exports.eth5 = exports.eth4 = exports.eth2 = exports.eth1 = exports.eth0 = exports.eth0_5 = exports.eth0_1 = void 0;
const ethers_1 = require("ethers");
const utils_1 = require("ethers/lib/utils");
exports.eth0_1 = (0, utils_1.parseUnits)("0.1", "ether");
exports.eth0_5 = (0, utils_1.parseUnits)("0.5", "ether");
exports.eth0 = ethers_1.BigNumber.from(0);
exports.eth1 = (0, utils_1.parseUnits)("1.0", "ether");
exports.eth2 = (0, utils_1.parseUnits)("2.0", "ether");
exports.eth4 = (0, utils_1.parseUnits)("4.0", "ether");
exports.eth5 = (0, utils_1.parseUnits)("5.0", "ether");
exports.eth8 = (0, utils_1.parseUnits)("4.0", "ether");
exports.eth9 = (0, utils_1.parseUnits)("1.0", "ether");
exports.eth10 = (0, utils_1.parseUnits)("10.0", "ether");
exports.eth50 = (0, utils_1.parseUnits)("50.0", "ether"); // 100 mill eth
exports.eth100 = (0, utils_1.parseUnits)("100.0", "ether"); // 100 mill eth
// export const EventState = {
//     Active: 0,
//     PaidFor: 1,
//     Completed: 2,
//     Cancelled: 3
// }
var EventState;
(function (EventState) {
    EventState[EventState["Active"] = 0] = "Active";
    EventState[EventState["PaidFor"] = 1] = "PaidFor";
    EventState[EventState["Completed"] = 2] = "Completed";
    EventState[EventState["Cancelled"] = 3] = "Cancelled";
})(EventState = exports.EventState || (exports.EventState = {}));
// export const EventActionEnum = {
//     Build: 0,
//     Dismantle: 1,
//     Produce: 2,
//     Burn: 3
// }
var EventActionEnum;
(function (EventActionEnum) {
    EventActionEnum[EventActionEnum["Build"] = 0] = "Build";
    EventActionEnum[EventActionEnum["Dismantle"] = 1] = "Dismantle";
    EventActionEnum[EventActionEnum["Produce"] = 2] = "Produce";
    EventActionEnum[EventActionEnum["Burn"] = 3] = "Burn";
})(EventActionEnum = exports.EventActionEnum || (exports.EventActionEnum = {}));
// export const AssetTypeEnum = {
//     None: 0,
//     Farm: 1,
//     Sawmill: 2,
//     Blacksmith: 3,
//     Quarry: 4,
//     Barrack: 5,
//     Stable: 6,
//     Market: 7,
//     Temple: 8,
//     University: 9,
//     Wall: 10,
//     Watchtower: 11,
//     Castle: 12,
//     Fortress: 13,
//     Population: 14
// }
var AssetTypeEnum;
(function (AssetTypeEnum) {
    AssetTypeEnum[AssetTypeEnum["None"] = 0] = "None";
    AssetTypeEnum[AssetTypeEnum["Farm"] = 1] = "Farm";
    AssetTypeEnum[AssetTypeEnum["Sawmill"] = 2] = "Sawmill";
    AssetTypeEnum[AssetTypeEnum["Blacksmith"] = 3] = "Blacksmith";
    AssetTypeEnum[AssetTypeEnum["Quarry"] = 4] = "Quarry";
    AssetTypeEnum[AssetTypeEnum["Barrack"] = 5] = "Barrack";
    AssetTypeEnum[AssetTypeEnum["Stable"] = 6] = "Stable";
    AssetTypeEnum[AssetTypeEnum["Market"] = 7] = "Market";
    AssetTypeEnum[AssetTypeEnum["Temple"] = 8] = "Temple";
    AssetTypeEnum[AssetTypeEnum["University"] = 9] = "University";
    AssetTypeEnum[AssetTypeEnum["Wall"] = 10] = "Wall";
    AssetTypeEnum[AssetTypeEnum["Watchtower"] = 11] = "Watchtower";
    AssetTypeEnum[AssetTypeEnum["Castle"] = 12] = "Castle";
    AssetTypeEnum[AssetTypeEnum["Fortress"] = 13] = "Fortress";
    AssetTypeEnum[AssetTypeEnum["Population"] = 14] = "Population";
})(AssetTypeEnum = exports.AssetTypeEnum || (exports.AssetTypeEnum = {}));
// export const AssetGroupEnum = {
//     None: 0,
//     Structure: 1,
//     Population: 2,
//     Commodity: 3,
//     Artifact: 4
// }
var AssetGroupEnum;
(function (AssetGroupEnum) {
    AssetGroupEnum[AssetGroupEnum["None"] = 0] = "None";
    AssetGroupEnum[AssetGroupEnum["Structure"] = 1] = "Structure";
    AssetGroupEnum[AssetGroupEnum["Population"] = 2] = "Population";
    AssetGroupEnum[AssetGroupEnum["Commodity"] = 3] = "Commodity";
    AssetGroupEnum[AssetGroupEnum["Artifact"] = 4] = "Artifact";
})(AssetGroupEnum = exports.AssetGroupEnum || (exports.AssetGroupEnum = {}));
//# sourceMappingURL=constants.js.map