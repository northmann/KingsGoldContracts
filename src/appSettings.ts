import { BigNumber  } from 'ethers';

import { eth0, eth1, eth0_5, eth9, eth10, eth90, eth100 } from './constants';

import contractAddresses from './contractAddresses.json';

export const appSettings: any = {
    generic: {
        baseGoldCost: eth1, // The cost of the gold against the base Chain token
        baseUnit: eth1, // The base unit of the game, everything is based their price on this

        provinceLimit: BigNumber.from(9),
        provinceCost: eth10, // The cost of the first province
        provinceDeposit: eth90, // The deposit of the first province
        provinceSpend: eth1, // The amount of gold that is left to spend af purchase of the first province
        //baseProvinceRequired: eth10, // The required amount of gold to buy a province = provinceCost + provinceDeposit + provinceSpend

        baseCommodityReward: eth1,
        timeBaseCost: BigNumber.from(60 * 60), // The base cost of the time in the game
        goldForTimeBaseCost: eth1, // The base cost of the gold for time in the game (1 gold per hour)

        provinceFoodInit: eth10, 
        provinceWoodInit: eth100,
        provinceRockInit: eth0,
        provinceIronInit: eth0,

        vassalTribute: eth0_5, // 50% of the vassal's gains are given to the king
    },
    1337: { // Localhost

        
        diamond: contractAddresses["Diamond"],
        gold: contractAddresses["KingsGold"],
        food: contractAddresses["Food"],
        wood: contractAddresses["Wood"],
        rock: contractAddresses["Rock"],
        iron: contractAddresses["Iron"],
        provinceNFT: contractAddresses["ProvinceNFT"],

    }
}

export function getAppSettings(chainId: number) : any {
    return { ...appSettings.generic, ...appSettings[chainId]};
}