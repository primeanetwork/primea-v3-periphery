/// <reference types="node" />
import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "hardhat-typechain";
import "hardhat-watcher";
import * as dotenv from "dotenv";
dotenv.config();

const LOW_OPTIMIZER_COMPILER_SETTINGS = {
  version: "0.7.6",
  settings: {
    evmVersion: "istanbul",
    optimizer: {
      enabled: true,
      runs: 2_000,
    },
    metadata: {
      bytecodeHash: "none",
    },
  },
};

const LOWEST_OPTIMIZER_COMPILER_SETTINGS = {
  version: "0.7.6",
  settings: {
    evmVersion: "istanbul",
    optimizer: {
      enabled: true,
      runs: 1_000,
    },
    metadata: {
      bytecodeHash: "none",
    },
  },
};

const DEFAULT_COMPILER_SETTINGS = {
  version: "0.7.6",
  settings: {
    evmVersion: "istanbul",
    optimizer: {
      enabled: true,
      runs: 1_000_000,
    },
    metadata: {
      bytecodeHash: "none",
    },
  },
};

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
    },
    mainnet: {
      url: process.env.INFURA_API_KEY
        ? `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`
        : process.env.NODE_URL || "",
    },
    goerli: {
      url: process.env.INFURA_API_KEY
        ? `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`
        : "",
    },
    arbitrum: {
      url: process.env.INFURA_API_KEY
        ? `https://arbitrum-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`
        : "",
    },
    arbitrumSepolia: {
      url: process.env.INFURA_API_KEY
        ? `https://arbitrum-sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`
        : "",
    },
    optimism: {
      url: process.env.INFURA_API_KEY
        ? `https://optimism-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`
        : "",
    },
    optimismSepolia: {
      url: process.env.INFURA_API_KEY
        ? `https://optimism-sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`
        : "",
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  },
  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS],
    overrides: {
      "contracts/NonfungiblePositionManager.sol": LOW_OPTIMIZER_COMPILER_SETTINGS,
      "contracts/test/MockTimeNonfungiblePositionManager.sol": LOW_OPTIMIZER_COMPILER_SETTINGS,
      "contracts/test/NFTDescriptorTest.sol": LOWEST_OPTIMIZER_COMPILER_SETTINGS,
      "contracts/NonfungibleTokenPositionDescriptor.sol": LOWEST_OPTIMIZER_COMPILER_SETTINGS,
      "contracts/libraries/NFTDescriptor.sol": LOWEST_OPTIMIZER_COMPILER_SETTINGS,
    },
  },
  watcher: {
    test: {
      tasks: [{ command: "test", params: { testFiles: ["{path}"] } }],
      files: ["./test/**/*"],
      verbose: true,
    },
  },
};

export default config;
