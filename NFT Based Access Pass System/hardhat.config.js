require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      evmVersion: "cancun",
    },
  },
  networks: {
        hardhat: {},

        megaeth: {
            url: process.env.MEGAETH_RPC_URL,
            accounts: [process.env.PRIVATE_KEY],
        },
    },
};
