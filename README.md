# Bank smart contract

## How to deploy the contract
- clone the repository `git clone https://github.com/Petar1304/trace_labs_task.git`
- run `mv .env_example .env` if you are on mac/linux or run `ren .env_example .env` on windows
- add private key and infura api key to `.env` file
- run `npm install`
- run `npx hardhat run scripts/deploy.ts --network goerli`

## Testing the contract
- run `npx hardhat test`
