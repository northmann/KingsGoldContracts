import { Contract } from 'ethers';

import contractAddresses from './contractAddresses.json';

import DiamondABI from './abi/Diamond.json';
import KingsGoldABI from './abi/KingsGold.json';
import WoodABI from './abi/Wood.json';
import RockABI from './abi/Rock.json';
import IronABI from './abi/Iron.json';
import FoodABI from './abi/Food.json';
import UserFacetABI from './abi/UserFacet.json';
import TreasuryFacetABI from './abi/TreasuryFacet.json';
import ProvinceFacetABI from './abi/ProvinceFacet.json';
import EventFacetABI from './abi/EventFacet.json';


export function getContracts(chainId: any, signer: any) : any {
    let result: any = {};

    result.diamond = new Contract(contractAddresses["Diamond"], DiamondABI, signer);
    result.kingsGold = new Contract(contractAddresses["KingsGold"], KingsGoldABI, signer);
    result.wood = new Contract(contractAddresses["Wood"], WoodABI, signer);
    result.rock = new Contract(contractAddresses["Rock"], RockABI, signer);
    result.iron = new Contract(contractAddresses["Iron"], IronABI, signer);
    result.food = new Contract(contractAddresses["Food"], FoodABI, signer);
    result.userFacet = new Contract(contractAddresses["Diamond"], UserFacetABI, signer);
    result.treasuryFacet = new Contract(contractAddresses["Diamond"], TreasuryFacetABI, signer);
    result.provinceFacet = new Contract(contractAddresses["Diamond"], ProvinceFacetABI, signer);
    result.eventFacet = new Contract(contractAddresses["Diamond"], EventFacetABI, signer);


    return result;
}

