import { BigNumber  } from 'ethers';

import { eth1, eth0_5, eth9, eth10, eth100 } from './constants';


export const appSettings: any = {
    generic: {
        provinceLimit: BigNumber.from(9),
        baseProvinceCost: eth9,
        baseProvinceSpend: eth1,
        baseProvinceRequired: eth10,
        baseCommodityReward: eth100,
        baseGoldCost: eth1,
        baseUnit: eth1,
        timeBaseCost: BigNumber.from(0),
        goldForTimeBaseCost: eth1,
        foodBaseCost: eth1,
        woodBaseCost: eth1,
        rockBaseCost: eth1,
        ironBaseCost: eth1,
        vassalTribute: eth0_5, // 50% of the vassal's gains are given to the king
    },
    1337: { // Localhost
    }
}

export function getAppSettings(chainId: number) : any {
    return { ...appSettings.generic, ...appSettings[chainId]};
}