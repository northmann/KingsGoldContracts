"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const config_1 = require("hardhat/config");
const basePath = "/contracts/game/";
const libraryBasePath = "/contracts/libraries/";
const generalBasePath = "/contracts/general/";
(0, config_1.task)("diamondABI", "Generates ABI file for diamond, includes all ABIs of facets").setAction(async () => {
    let files = fs.readdirSync("." + basePath);
    let abi = [];
    for (const file of files) {
        const jsonFile = file.replace("sol", "json");
        let json = fs.readFileSync(`./artifacts/${basePath}${file}/${jsonFile}`);
        json = JSON.parse(json);
        abi.push(...json.abi);
    }
    files = fs.readdirSync("." + libraryBasePath);
    for (const file of files) {
        const jsonFile = file.replace("sol", "json");
        let json = fs.readFileSync(`./artifacts/${libraryBasePath}${file}/${jsonFile}`);
        json = JSON.parse(json);
        abi.push(...json.abi);
    }
    files = fs.readdirSync("." + generalBasePath);
    for (const file of files) {
        const jsonFile = file.replace("sol", "json");
        let json = fs.readFileSync(`./artifacts/${generalBasePath}${file}/${jsonFile}`);
        json = JSON.parse(json);
        abi.push(...json.abi);
    }
    let finalAbi = JSON.stringify(abi);
    fs.writeFileSync("./frontend/src/abi/diamond.json", finalAbi);
    console.log("ABI written to diamondABI/diamond.json");
});
//# sourceMappingURL=generateDiamondAbi.js.map