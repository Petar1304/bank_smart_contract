import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from 'dotenv'; 
dotenv.config();
// import * as dotenv from "dotenv";


const config: HardhatUserConfig = {
  solidity: "0.8.20",
  mocha: {
    timeout: 1000000000,
  },
  networks: {
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  }
};

export default config;
