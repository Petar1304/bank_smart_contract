import { ethers } from "hardhat";

async function main() {

  const [address1] = await ethers.getSigners();

  const initalDeposit = ethers.parseEther("1000");
  const T = 10; // in seconds

  const token = await ethers.deployContract("Token");
  await token.waitForDeployment();

  await token.mint(address1, initalDeposit);

  const bank = await ethers.deployContract("Bank", [token.target, initalDeposit, T]);

  await bank.waitForDeployment();

  // deposit tokens for rewards
  await token.transfer(bank.target, initalDeposit);

  console.log(
    `Bank with ${ethers.formatEther(
      initalDeposit
    )} ERC20 tokens and time constant ${T} deployed to ${bank.target}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
