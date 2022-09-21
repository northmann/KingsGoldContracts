"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getArmyUnitTypeRawData = exports.armyUnitTypes = exports.ArmyUnitDefault = exports.ArmyState = exports.ArmyUnitType = void 0;
var ArmyUnitType;
(function (ArmyUnitType) {
    ArmyUnitType[ArmyUnitType["None"] = 0] = "None";
    ArmyUnitType[ArmyUnitType["Militia"] = 1] = "Militia";
    ArmyUnitType[ArmyUnitType["Soldier"] = 2] = "Soldier";
    ArmyUnitType[ArmyUnitType["Knight"] = 3] = "Knight";
    ArmyUnitType[ArmyUnitType["Archer"] = 4] = "Archer";
    ArmyUnitType[ArmyUnitType["Catapult"] = 5] = "Catapult";
    ArmyUnitType[ArmyUnitType["Last"] = 6] = "Last";
})(ArmyUnitType = exports.ArmyUnitType || (exports.ArmyUnitType = {}));
var ArmyState;
(function (ArmyState) {
    ArmyState[ArmyState["Idle"] = 0] = "Idle";
    ArmyState[ArmyState["Moving"] = 1] = "Moving";
    ArmyState[ArmyState["Attacking"] = 2] = "Attacking";
    ArmyState[ArmyState["Defending"] = 3] = "Defending";
    ArmyState[ArmyState["Retreating"] = 4] = "Retreating";
    ArmyState[ArmyState["Last"] = 5] = "Last";
})(ArmyState = exports.ArmyState || (exports.ArmyState = {}));
exports.ArmyUnitDefault = {
    armyUnitTypeId: ArmyUnitType.None,
    openAttack: 0,
    openDefense: 0,
    seigeAttack: 0,
    seigeDefense: 0,
    speed: 5,
    priority: 0,
    image100: "default.webp",
};
exports.armyUnitTypes = {
    [ArmyUnitType.None]: {
        ...exports.ArmyUnitDefault,
    },
    [ArmyUnitType.Militia]: {
        ...exports.ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Militia,
        openAttack: 1,
        openDefense: 1,
        seigeAttack: 0,
        seigeDefense: 1,
        speed: 7,
        priority: 1,
        title: "Militia",
        description: "A militia is a military force that is raised from the civil population to supplement a regular army in an emergency.",
    },
    [ArmyUnitType.Soldier]: {
        ...exports.ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Soldier,
        openAttack: 2,
        openDefense: 3,
        seigeAttack: 2,
        seigeDefense: 4,
        speed: 5,
        priority: 2,
        title: "Soldier",
        description: "A soldier is a person who fights as part of an organised, land-based armed force.",
    },
    [ArmyUnitType.Archer]: {
        ...exports.ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Archer,
        openAttack: 3,
        openDefense: 1,
        seigeAttack: 3,
        seigeDefense: 4,
        speed: 6,
        priority: 4,
        title: "Archer",
        description: "An archer is a person who uses a bow to shoot arrows.",
    },
    [ArmyUnitType.Knight]: {
        ...exports.ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Knight,
        openAttack: 4,
        openDefense: 3,
        seigeAttack: 1,
        seigeDefense: 5,
        speed: 9,
        priority: 10,
        title: "Knight",
        description: "A knight is a person granted an honorary title of knighthood by a monarch or other political leader for service to the monarch or country, especially in a military capacity.",
    },
    [ArmyUnitType.Catapult]: {
        ...exports.ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Catapult,
        openAttack: 0,
        openDefense: 0,
        seigeAttack: 5,
        seigeDefense: 1,
        speed: 3,
        priority: 20,
        title: "Catapult",
        description: "A catapult is a ballistic device used to launch a projectile a great distance without the aid of explosive devices. Very useful for sieges.",
    },
};
function getArmyUnitTypeRawData() {
    let data = Object.keys(exports.armyUnitTypes).map((key) => {
        let r = { ...exports.armyUnitTypes[key] };
        delete r.image100;
        delete r.title;
        delete r.description;
        return r;
    });
    return data;
}
exports.getArmyUnitTypeRawData = getArmyUnitTypeRawData;
//# sourceMappingURL=army.js.map