"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deployCoreGame = void 0;
const config_1 = require("hardhat/config");
const utils_1 = require("../lib/utils");
const diamondCutFacet_1 = require("./diamondCutFacet");
// --------------------------------------------------------------------------------------------
(0, config_1.task)("deployGame", "Deploy the core game")
    .addFlag("useledger", "Set to true if Ledger should be used for signing")
    .setAction(async (taskArgs, hre) => {
    //Instantiate the Signer
    let signer = await (0, utils_1.getSigner)(hre, undefined, taskArgs.useledger);
    return deployCoreGame(hre, signer);
});
async function deployCoreGame(hre, signer) {
    const diamondAddress = await (0, diamondCutFacet_1.deployDiamondCore)(hre, signer);
    await (0, diamondCutFacet_1.deployAllGameFacets)(hre, diamondAddress, signer);
    return diamondAddress;
}
exports.deployCoreGame = deployCoreGame;
//# sourceMappingURL=game.js.map