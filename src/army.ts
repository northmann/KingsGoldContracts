import { BigNumber, ethers } from 'ethers';
import { EventState, EventActionEnum, AssetTypeEnum, AssetProductEnum, eth0_1, eth0_5, eth0, eth1, eth10, eth100, eth2, eth4, eth5, eth50, eth8, eth9  } from './constants';
import { parseUnits } from 'ethers/lib/utils';

export enum ArmyUnitType {
    None = 0,
    Militia = 1,
    Soldier,
    Knight,
    Archer,
    Catapult,
    Last
}

export enum ArmyState {
    Idle = 0,
    Moving,
    Attacking,
    Defending,
    Retreating,
    Last
}


export const ArmyUnitDefault = {
    armyUnitTypeId: ArmyUnitType.None,
    openAttack: 0,
    openDefense: 0,
    seigeAttack: 0,
    seigeDefense: 0,
    speed : 0,
    priority: 0,
    image100: "default.webp",
}

export const ArmyUnit = {
    armyUnitTypeId: ArmyUnitType.None,
    amount: 0,
    shares: 0,
}


export const armyUnitTypes: any = {
    [ArmyUnitType.None]: {
        ...ArmyUnitDefault,
    },
    [ArmyUnitType.Militia]: {
        ...ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Militia,
        openAttack: 1,
        openDefense: 1,
        seigeAttack: 0,
        seigeDefense: 1,
        speed : 7,
        priority: 1,
        title: "Militia",
        description: "A militia is a military force that is raised from the civil population to supplement a regular army in an emergency.",
    },
    [ArmyUnitType.Soldier]: {
        ...ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Soldier,
        openAttack: 2,
        openDefense: 3,
        seigeAttack: 2,
        seigeDefense: 4,
        speed : 5,
        priority: 2,
        title: "Soldier",
        description: "A soldier is a person who fights as part of an organised, land-based armed force.",
    },
    [ArmyUnitType.Archer]: {
        ...ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Archer,
        openAttack: 3,
        openDefense: 1,
        seigeAttack: 3,
        seigeDefense: 4,
        speed : 6,
        priority: 4,
        title: "Archer",
        description: "An archer is a person who uses a bow to shoot arrows.",
    },
    [ArmyUnitType.Knight]: {
        ...ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Knight,
        openAttack: 4,
        openDefense: 3,
        seigeAttack: 1,
        seigeDefense: 5,
        speed : 9,
        priority: 10,
        title: "Knight",
        description: "A knight is a person granted an honorary title of knighthood by a monarch or other political leader for service to the monarch or country, especially in a military capacity.",
    },
    [ArmyUnitType.Catapult]: {
        ...ArmyUnitDefault,
        armyUnitTypeId: ArmyUnitType.Catapult,
        openAttack: 0,
        openDefense: 0,
        seigeAttack: 5,
        seigeDefense: 1,
        speed : 3,
        priority: 20,
        title: "Catapult",
        description: "A catapult is a ballistic device used to launch a projectile a great distance without the aid of explosive devices. Very useful for sieges.",
    },
}



export function getArmyUnitTypeRawData(): any {
    let data = Object.keys(armyUnitTypes).map((key:any) => 
    {
        let r = { ...armyUnitTypes[key] };
        delete r.image100;
        delete r.title;
        delete r.description;
        return r;
    } );

     return data;
}
