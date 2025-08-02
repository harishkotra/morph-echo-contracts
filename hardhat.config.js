require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    morphTestnet: {
      url: `https://rpc-quicknode-holesky.morphl2.io/`,
      accounts: [process.env.PRIVATE_KEY],
      gasPrice: 2000000000 // 2 gwei in wei
    }
  }
};