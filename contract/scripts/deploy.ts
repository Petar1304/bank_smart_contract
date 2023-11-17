import { ethers } from "hardhat";

async function main() {

  const [address1, address2] = await ethers.getSigners();

  const initalDeposit = ethers.parseEther("0.001");
  const T = 100;

  const token = await ethers.deployContract("Token");
  await token.waitForDeployment();
 
  await token.mint(address1, ethers.parseEther("100"));

  const bank = await ethers.deployContract("Bank", [T]);

  await bank.waitForDeployment();

  // deposit tokens for rewards
  await token.transfer(bank.target, initalDeposit);

  console.log(
    `Bank with ${ethers.formatEther(
      initalDeposit
    )}ETH and time constant ${T} deployed to ${bank.target}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
