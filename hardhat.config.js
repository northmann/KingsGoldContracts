
/* global ethers task */
require("@nomiclabs/hardhat-ethers");
require('@nomiclabs/hardhat-waffle');
require('@openzeppelin/hardhat-upgrades');
require('hardhat-abi-exporter');
require('hardhat-contract-sizer');

//require("./tasks/generateDiamondABI");
require("./dist/tasks/diamondCutFacet");
require("./dist/tasks/ownershipFacet");
require("./dist/tasks/userFacet");

require("./tasks/ksg");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})



// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: '0.8.6',
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  networks: {
    hardhat: {
      chainId: 1337,
      // mining: {
      //   auto: false,
      //   interval: [1000, 2000] // mine between 1000 and 2000 ms
      // }
    },
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: false,
    strict: true,
    only: [], //':ERC20$'
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  abiExporter: {
    path: './src/abi',
    runOnCompile: true,
    except: ["IERC165.sol"],
    clear: false,
    flat: true,
    spacing: 2
  },
  mocha: {
    timeout: 20000000,
  }
}
