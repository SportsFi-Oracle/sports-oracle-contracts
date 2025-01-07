/** @type import('hardhat/config').HardhatUserConfig */
import { extendConfig, HardhatUserConfig, task } from 'hardhat/config';
import '@nomiclabs/hardhat-ethers';
import '@nomicfoundation/hardhat-ignition';
import 'dotenv/config';


const config: HardhatUserConfig = {

  solidity: "0.8.0",
  networks: {
    sx_testnet: {
        url: 'https://rpc.toronto.sx.technology',
        accounts: [process.env.PRIVATE_KEY!],
        chainId: 647,
    }
  }

}

export default config;