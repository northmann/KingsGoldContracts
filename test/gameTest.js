const { ethers } = require("hardhat");
/* global describe it before ethers */

const {
  getSelectors,
  FacetCutAction,
  removeSelectors,
  findAddressPositionInFacets
} = require('../scripts/libraries/diamond.js')

const { deployDiamond }    = require('../scripts/deploy.js')
const { fundUserWithGold } = require('../scripts/libraries/builder.js');

const { assert } = require('chai');
const { BigNumber } = require("ethers");
const { formatUnits } = require("ethers/lib/utils.js");



describe('GameTest', async function () {
  let global = {}
  let diamond
  let diamondAddress
  let diamondCutFacet
  let diamondLoupeFacet
  let ownershipFacet
  let tx
  let receipt
  let result
  let singles
  let initializeData
  const addresses = []
  let bigNumber1eth = ethers.utils.parseUnits("1.0", "ether"); // 100 mill eth
  let bigNumber100eth = ethers.utils.parseUnits("100.0", "ether"); // 100 mill eth


  before(async function () {
    this.timeout(20000);

    global = await deployDiamond();

    //diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    global.diamondLoupeFacet = await  ('DiamondLoupeFacet', global.diamond.address)
    //ownershipFacet = await ethers.getContractAt('OwnershipFacet', diamondAddress)
  })

  it('should have the correct provinceNFT address after initilization', async function () { // The full deployment
      this.timeout(20000);

      let provinceFacet = await ethers.getContractAt('ProvinceFacet', global.diamond.address)
      let provinceNFTAddress = await provinceFacet.getProvinceNFT();
      assert.equal(provinceNFTAddress, global.initializeData.provinceNFT);
    })

    
  it('should be able to give test user some gold coins', async function () { // The full deployment
    await fundUserWithGold(global.user);

    let balance = await global.gold.balanceOf(global.user.address);
    assert.equal(balance.toString(), bigNumber100eth.toString());
  })

  it('should be able to buy a province', async () => {
    // First allow the game to spend my coins.
    await fundUserWithGold(global.user);

    let goldBalanceBefore = await global.gold.balanceOf(global.user.address);

    let provinceFacet = await ethers.getContractAt('ProvinceFacet', global.diamond.address, global.user);
    let tx = await provinceFacet.createProvince("Test");
    await tx.wait();

    // let provinceCount = await provinceFacet.getUserProvinceCount();
    // assert.equal(provinceCount, 1);
    
    // let province = await provinceFacet.getUserProvince(0);
    // assert.equal(province.name, "Test");

    let goldBalanceAfter = await global.gold.balanceOf(global.user.address);
    //let expectedBalance = bigNumber100eth.sub(initializeData.provinceCost.mul(BigNumber.from(9)));
    
    let expectedBalance = goldBalanceBefore.sub(global.initializeData.provinceCost);
    assert.equal(goldBalanceAfter.toString(), expectedBalance.toString());
  })

  // it('facets should have the right function selectors -- call to facetFunctionSelectors function', async () => {
  //   let selectors = getSelectors(diamondCutFacet)
  //   result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0])
  //   assert.sameMembers(result, selectors)
  //   selectors = getSelectors(diamondLoupeFacet)
  //   result = await diamondLoupeFacet.facetFunctionSelectors(addresses[1])
  //   assert.sameMembers(result, selectors)
  //   selectors = getSelectors(ownershipFacet)
  //   result = await diamondLoupeFacet.facetFunctionSelectors(addresses[2])
  //   assert.sameMembers(result, selectors)
  // })

  // it('selectors should be associated to facets correctly -- multiple calls to facetAddress function', async () => {
  //   assert.equal(
  //     addresses[0],
  //     await diamondLoupeFacet.facetAddress('0x1f931c1c')
  //   )
  //   assert.equal(
  //     addresses[1],
  //     await diamondLoupeFacet.facetAddress('0xcdffacc6')
  //   )
  //   assert.equal(
  //     addresses[1],
  //     await diamondLoupeFacet.facetAddress('0x01ffc9a7')
  //   )
  //   assert.equal(
  //     addresses[2],
  //     await diamondLoupeFacet.facetAddress('0xf2fde38b')
  //   )
  // })

  // it('should add test1 functions', async () => {
  //   const Test1Facet = await ethers.getContractFactory('Test1Facet')
  //   const test1Facet = await Test1Facet.deploy()
  //   await test1Facet.deployed()
  //   addresses.push(test1Facet.address)
  //   const selectors = getSelectors(test1Facet).remove(['supportsInterface(bytes4)'])
  //   tx = await diamondCutFacet.diamondCut(
  //     [{
  //       facetAddress: test1Facet.address,
  //       action: FacetCutAction.Add,
  //       functionSelectors: selectors
  //     }],
  //     ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
  //   receipt = await tx.wait()
  //   if (!receipt.status) {
  //     throw Error(`Diamond upgrade failed: ${tx.hash}`)
  //   }
  //   result = await diamondLoupeFacet.facetFunctionSelectors(test1Facet.address)
  //   assert.sameMembers(result, selectors)
  // })

  // it('should test function call', async () => {
  //   const test1Facet = await ethers.getContractAt('Test1Facet', diamondAddress)
  //   await test1Facet.test1Func10()
  // })

  // it('should replace supportsInterface function', async () => {
  //   const Test1Facet = await ethers.getContractFactory('Test1Facet')
  //   const selectors = getSelectors(Test1Facet).get(['supportsInterface(bytes4)'])
  //   const testFacetAddress = addresses[3]
  //   tx = await diamondCutFacet.diamondCut(
  //     [{
  //       facetAddress: testFacetAddress,
  //       action: FacetCutAction.Replace,
  //       functionSelectors: selectors
  //     }],
  //     ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
  //   receipt = await tx.wait()
  //   if (!receipt.status) {
  //     throw Error(`Diamond upgrade failed: ${tx.hash}`)
  //   }
  //   result = await diamondLoupeFacet.facetFunctionSelectors(testFacetAddress)
  //   assert.sameMembers(result, getSelectors(Test1Facet))
  // })

  // it('should add test2 functions', async () => {
  //   const Test2Facet = await ethers.getContractFactory('Test2Facet')
  //   const test2Facet = await Test2Facet.deploy()
  //   await test2Facet.deployed()
  //   addresses.push(test2Facet.address)
  //   const selectors = getSelectors(test2Facet)
  //   tx = await diamondCutFacet.diamondCut(
  //     [{
  //       facetAddress: test2Facet.address,
  //       action: FacetCutAction.Add,
  //       functionSelectors: selectors
  //     }],
  //     ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
  //   receipt = await tx.wait()
  //   if (!receipt.status) {
  //     throw Error(`Diamond upgrade failed: ${tx.hash}`)
  //   }
  //   result = await diamondLoupeFacet.facetFunctionSelectors(test2Facet.address)
  //   assert.sameMembers(result, selectors)
  // })

  // it('should remove some test2 functions', async () => {
  //   const test2Facet = await ethers.getContractAt('Test2Facet', diamondAddress)
  //   const functionsToKeep = ['test2Func1()', 'test2Func5()', 'test2Func6()', 'test2Func19()', 'test2Func20()']
  //   const selectors = getSelectors(test2Facet).remove(functionsToKeep)
  //   tx = await diamondCutFacet.diamondCut(
  //     [{
  //       facetAddress: ethers.constants.AddressZero,
  //       action: FacetCutAction.Remove,
  //       functionSelectors: selectors
  //     }],
  //     ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
  //   receipt = await tx.wait()
  //   if (!receipt.status) {
  //     throw Error(`Diamond upgrade failed: ${tx.hash}`)
  //   }
  //   result = await diamondLoupeFacet.facetFunctionSelectors(addresses[4])
  //   assert.sameMembers(result, getSelectors(test2Facet).get(functionsToKeep))
  // })

  // it('should remove some test1 functions', async () => {
  //   const test1Facet = await ethers.getContractAt('Test1Facet', diamondAddress)
  //   const functionsToKeep = ['test1Func2()', 'test1Func11()', 'test1Func12()']
  //   const selectors = getSelectors(test1Facet).remove(functionsToKeep)
  //   tx = await diamondCutFacet.diamondCut(
  //     [{
  //       facetAddress: ethers.constants.AddressZero,
  //       action: FacetCutAction.Remove,
  //       functionSelectors: selectors
  //     }],
  //     ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
  //   receipt = await tx.wait()
  //   if (!receipt.status) {
  //     throw Error(`Diamond upgrade failed: ${tx.hash}`)
  //   }
  //   result = await diamondLoupeFacet.facetFunctionSelectors(addresses[3])
  //   assert.sameMembers(result, getSelectors(test1Facet).get(functionsToKeep))
  // })

  // it('remove all functions and facets except \'diamondCut\' and \'facets\'', async () => {
  //   let selectors = []
  //   let facets = await diamondLoupeFacet.facets()
  //   for (let i = 0; i < facets.length; i++) {
  //     selectors.push(...facets[i].functionSelectors)
  //   }
  //   selectors = removeSelectors(selectors, ['facets()', 'diamondCut(tuple(address,uint8,bytes4[])[],address,bytes)'])
  //   tx = await diamondCutFacet.diamondCut(
  //     [{
  //       facetAddress: ethers.constants.AddressZero,
  //       action: FacetCutAction.Remove,
  //       functionSelectors: selectors
  //     }],
  //     ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
  //   receipt = await tx.wait()
  //   if (!receipt.status) {
  //     throw Error(`Diamond upgrade failed: ${tx.hash}`)
  //   }
  //   facets = await diamondLoupeFacet.facets()
  //   assert.equal(facets.length, 2)
  //   assert.equal(facets[0][0], addresses[0])
  //   assert.sameMembers(facets[0][1], ['0x1f931c1c'])
  //   assert.equal(facets[1][0], addresses[1])
  //   assert.sameMembers(facets[1][1], ['0x7a0ed627'])
  // })

  // it('add most functions and facets', async () => {
  //   const diamondLoupeFacetSelectors = getSelectors(diamondLoupeFacet).remove(['supportsInterface(bytes4)'])
  //   const Test1Facet = await ethers.getContractFactory('Test1Facet')
  //   const Test2Facet = await ethers.getContractFactory('Test2Facet')
  //   // Any number of functions from any number of facets can be added/replaced/removed in a
  //   // single transaction
  //   const cut = [
  //     {
  //       facetAddress: addresses[1],
  //       action: FacetCutAction.Add,
  //       functionSelectors: diamondLoupeFacetSelectors.remove(['facets()'])
  //     },
  //     {
  //       facetAddress: addresses[2],
  //       action: FacetCutAction.Add,
  //       functionSelectors: getSelectors(ownershipFacet)
  //     },
  //     {
  //       facetAddress: addresses[3],
  //       action: FacetCutAction.Add,
  //       functionSelectors: getSelectors(Test1Facet)
  //     },
  //     {
  //       facetAddress: addresses[4],
  //       action: FacetCutAction.Add,
  //       functionSelectors: getSelectors(Test2Facet)
  //     }
  //   ]
  //   tx = await diamondCutFacet.diamondCut(cut, ethers.constants.AddressZero, '0x', { gasLimit: 8000000 })
  //   receipt = await tx.wait()
  //   if (!receipt.status) {
  //     throw Error(`Diamond upgrade failed: ${tx.hash}`)
  //   }
  //   const facets = await diamondLoupeFacet.facets()
  //   const facetAddresses = await diamondLoupeFacet.facetAddresses()
  //   assert.equal(facetAddresses.length, 5)
  //   assert.equal(facets.length, 5)
  //   assert.sameMembers(facetAddresses, addresses)
  //   assert.equal(facets[0][0], facetAddresses[0], 'first facet')
  //   assert.equal(facets[1][0], facetAddresses[1], 'second facet')
  //   assert.equal(facets[2][0], facetAddresses[2], 'third facet')
  //   assert.equal(facets[3][0], facetAddresses[3], 'fourth facet')
  //   assert.equal(facets[4][0], facetAddresses[4], 'fifth facet')
  //   assert.sameMembers(facets[findAddressPositionInFacets(addresses[0], facets)][1], getSelectors(diamondCutFacet))
  //   assert.sameMembers(facets[findAddressPositionInFacets(addresses[1], facets)][1], diamondLoupeFacetSelectors)
  //   assert.sameMembers(facets[findAddressPositionInFacets(addresses[2], facets)][1], getSelectors(ownershipFacet))
  //   assert.sameMembers(facets[findAddressPositionInFacets(addresses[3], facets)][1], getSelectors(Test1Facet))
  //   assert.sameMembers(facets[findAddressPositionInFacets(addresses[4], facets)][1], getSelectors(Test2Facet))
  // })
})
