import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

async function getContracts() {
  const [address1, address2] = await ethers.getSigners();

  const initalDeposit = ethers.parseEther("100");
  const T = 100;

  const token = await ethers.deployContract("Token");
  await token.waitForDeployment();

  await token.mint(address1, initalDeposit);

  const bank = await ethers.deployContract("Bank", [T]);

  await bank.waitForDeployment();

  // deposit tokens for rewards
  await token.transfer(bank.target, initalDeposit);

  return [bank, token];
}

describe("Bank", function () {


  describe("Deployment", function () {

    it("Deploy contract", async function () {
      const [bank, token] = await getContracts();

      expect(1).to.equal(1);
    }
    );
  });
});
