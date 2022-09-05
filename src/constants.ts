import { BigNumber } from 'ethers';
import { parseUnits } from 'ethers/lib/utils';


export const eth0_1 = parseUnits("0.1", "ether");
export const eth0_5 = parseUnits("0.5", "ether");
export const eth0 = BigNumber.from(0);
export const eth1 = parseUnits("1.0", "ether");
export const eth2 = parseUnits("2.0", "ether");
export const eth4 = parseUnits("4.0", "ether");
export const eth5 = parseUnits("5.0", "ether");
export const eth8 = parseUnits("4.0", "ether");
export const eth9 = parseUnits("1.0", "ether");
export const eth10 = parseUnits("10.0", "ether");
export const eth50 = parseUnits("50.0", "ether"); // 100 mill eth
export const eth100 = parseUnits("100.0", "ether"); // 100 mill eth


// export const EventState = {
//     Active: 0,
//     PaidFor: 1,
//     Completed: 2,
//     Cancelled: 3
// }

export enum EventState {
    Active = 0,
    PaidFor,
    Completed,
    Cancelled
}

// export const EventActionEnum = {
//     Build: 0,
//     Dismantle: 1,
//     Produce: 2,
//     Burn: 3
// }



export enum EventActionEnum {
    Build= 0,
    Dismantle,
    Produce,
    Burn
}
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

export enum AssetTypeEnum {
    None = 0,
    Farm,
    Sawmill,
    Blacksmith,
    Quarry,
    Barrack,
    Stable,
    Market,
    Temple,
    University,
    Wall,
    Watchtower,
    Castle,
    Fortress,
    Population
}


// export const AssetGroupEnum = {
//     None: 0,
//     Structure: 1,
//     Population: 2,
//     Commodity: 3,
//     Artifact: 4
// }

export enum AssetGroupEnum  {
    None = 0,
    Structure,
    Population,
    Commodity,
    Artifact
}