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
export const eth50 = parseUnits("50.0", "ether"); 
export const eth90 = parseUnits("90.0", "ether");  
export const eth100 = parseUnits("100.0", "ether"); 

export enum EventState {
    Active = 0,
    PaidFor,
    Completed,
    Cancelled
}


export enum EventActionEnum {
    Build= 0,
    Dismantle,
    Produce,
    Burn
}

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

export enum AssetGroupEnum  {
    None = 0,
    Structure,
    Population,
    Commodity,
    Artifact
}