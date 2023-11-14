import { ethers } from "hardhat";

async function main() {

  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const T = currentTimestampInSeconds + 60;

  const initalDeposit = ethers.parseEther("0.001");

  const bank = await ethers.deployContract("Bank", [T], { value: initalDeposit });

  await bank.waitForDeployment();

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
