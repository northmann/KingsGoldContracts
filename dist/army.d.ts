export declare enum ArmyUnitType {
    None = 0,
    Militia = 1,
    Soldier = 2,
    Knight = 3,
    Archer = 4,
    Catapult = 5,
    Last = 6
}
export declare enum ArmyState {
    Idle = 0,
    Moving = 1,
    Attacking = 2,
    Defending = 3,
    Retreating = 4,
    Last = 5
}
export declare const ArmyUnitDefault: {
    armyUnitTypeId: ArmyUnitType;
    openAttack: number;
    openDefense: number;
    seigeAttack: number;
    seigeDefense: number;
    speed: number;
    priority: number;
    image100: string;
};
export declare const armyUnitTypes: any;
export declare function getArmyUnitTypeRawData(): any;
//# sourceMappingURL=army.d.ts.map