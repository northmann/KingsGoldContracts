const { ethers } = require("hardhat");
/* global describe it before ethers */

//const { initAppStoreAssets, initAppStoreAssetAction} = require("../scripts/libraries/configuration.js");
const { getAssetData, getAssetActionData } = require("../scripts/data/Assets.js");

const { assert } = require('chai');
const { BigNumber } = require("ethers");



describe('ConfigTest', async function () {
  let global = {}

  before(async function () {
  })

  it('should have the correct format', async function () { // The full deployment
      this.timeout(20000);

      try {
        let datas = getAssetActionData();
        for(let data of datas) {
          console.log(data);
        }
  
      } catch (error) {
          console.log(error);
      }

    })

    
})
