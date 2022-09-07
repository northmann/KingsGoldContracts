"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getContracts = void 0;
const ethers_1 = require("ethers");
const contractAddresses_json_1 = __importDefault(require("./contractAddresses.json"));
const Diamond_json_1 = __importDefault(require("./abi/Diamond.json"));
const KingsGold_json_1 = __importDefault(require("./abi/KingsGold.json"));
const Wood_json_1 = __importDefault(require("./abi/Wood.json"));
const Rock_json_1 = __importDefault(require("./abi/Rock.json"));
const Iron_json_1 = __importDefault(require("./abi/Iron.json"));
const Food_json_1 = __importDefault(require("./abi/Food.json"));
const UserFacet_json_1 = __importDefault(require("./abi/UserFacet.json"));
const TreasuryFacet_json_1 = __importDefault(require("./abi/TreasuryFacet.json"));
const ProvinceFacet_json_1 = __importDefault(require("./abi/ProvinceFacet.json"));
const EventFacet_json_1 = __importDefault(require("./abi/EventFacet.json"));
function getContracts(chainId, signer) {
    let result = {};
    result.diamond = new ethers_1.Contract(contractAddresses_json_1.default["Diamond"], Diamond_json_1.default, signer);
    result.kingsGold = new ethers_1.Contract(contractAddresses_json_1.default["KingsGold"], KingsGold_json_1.default, signer);
    result.wood = new ethers_1.Contract(contractAddresses_json_1.default["Wood"], Wood_json_1.default, signer);
    result.rock = new ethers_1.Contract(contractAddresses_json_1.default["Rock"], Rock_json_1.default, signer);
    result.iron = new ethers_1.Contract(contractAddresses_json_1.default["Iron"], Iron_json_1.default, signer);
    result.food = new ethers_1.Contract(contractAddresses_json_1.default["Food"], Food_json_1.default, signer);
    result.userFacet = new ethers_1.Contract(contractAddresses_json_1.default["Diamond"], UserFacet_json_1.default, signer);
    result.treasuryFacet = new ethers_1.Contract(contractAddresses_json_1.default["Diamond"], TreasuryFacet_json_1.default, signer);
    result.provinceFacet = new ethers_1.Contract(contractAddresses_json_1.default["Diamond"], ProvinceFacet_json_1.default, signer);
    result.eventFacet = new ethers_1.Contract(contractAddresses_json_1.default["Diamond"], EventFacet_json_1.default, signer);
    return result;
}
exports.getContracts = getContracts;
//# sourceMappingURL=contracts.js.map