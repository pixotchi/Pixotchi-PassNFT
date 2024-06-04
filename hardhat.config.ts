import { HardhatUserConfig } from "hardhat/config";
//import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-abi-exporter";
import * as dotenv from "dotenv";
dotenv.config();

import * as tdly from "@tenderly/hardhat-tenderly";
tdly.setup();
tdly.setup({automaticVerifications: false});

let {
  TENDERLY_USERNAME,
  TENDERLY_PROJECT,
  TENDERLY_ACCESS_KEY,
  TENDERLY_PROJECT_SLUG,
  ETHERSCAN_API_KEY,
  BASESCAN_API_KEY,
  BASE_SEPOLIA_URL,
  BASE_SEPOLIA_MNEMONIC,
  BASE_URL,
  BASE_MNEMONIC,
  DEVNET_RPC_URL,
} = process.env;

ETHERSCAN_API_KEY ??= ""
BASESCAN_API_KEY ??= ""
TENDERLY_USERNAME ??= ""
TENDERLY_PROJECT ??= ""



const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200
        ,
        details: {
          yulDetails: {
            optimizerSteps: "u",
          },
        },
      },
    },
  },


  networks: {
    base: {
      url: BASE_URL,
      accounts: {
        initialIndex: 0,
        count: 20,
        mnemonic: BASE_MNEMONIC,
        path: "m/44'/60'/0'/0",
      }
    },

    baseSepolia: {
      chainId: 84532,
      url: BASE_SEPOLIA_URL,
      accounts: {
        initialIndex: 0,
        count: 20,
        mnemonic: BASE_SEPOLIA_MNEMONIC,
        path: "m/44'/60'/0'/0",
      },
      gasMultiplier: 1.01
    },

    tenderly: {
      url: DEVNET_RPC_URL,
      accounts: {
        initialIndex: 0,
        count: 40,
        mnemonic: BASE_MNEMONIC,
        path: "m/44'/60'/0'/0",
      },
    }
  },
  etherscan: {
    apiKey: {
      goerli: ETHERSCAN_API_KEY,
      sepolia: ETHERSCAN_API_KEY,
      base: BASESCAN_API_KEY,
      baseSepolia: BASESCAN_API_KEY
    },

    customChains: [
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org"
        }
      }
    ]
  },
  sourcify: {
    enabled: true
  },
  tenderly: {
    username: TENDERLY_USERNAME,
    project: TENDERLY_PROJECT,
    privateVerification: true,
    forkNetwork: "tenderly",
    accessKey: TENDERLY_ACCESS_KEY,
  }


};

export default config;
