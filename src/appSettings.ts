import { BigNumber  } from 'ethers';
import { parseUnits } from 'ethers/lib/utils';

const eth0_1 = parseUnits("0.1", "ether");
const eth0_5 = parseUnits("0.5", "ether");
const eth0 = BigNumber.from(0);
const eth1 = parseUnits("1.0", "ether");
const eth2 = parseUnits("2.0", "ether");
const eth4 = parseUnits("4.0", "ether");
const eth5 = parseUnits("5.0", "ether");
const eth8 = parseUnits("4.0", "ether");
const eth9 = parseUnits("1.0", "ether");
const eth10 = parseUnits("10.0", "ether");
const eth50 = parseUnits("50.0", "ether"); // 100 mill eth
const eth100 = parseUnits("100.0", "ether"); // 100 mill eth


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
