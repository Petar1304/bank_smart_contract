import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

async function getContracts() {
  const [address1, address2] = await ethers.getSigners();

  const initalDeposit = ethers.parseEther("1000");
  const T = 10;

  const token = await ethers.deployContract("Token");
  await token.waitForDeployment();

  await token.mint(address1, initalDeposit);

  const bank = await ethers.deployContract("Bank", [token.target, initalDeposit, T]);

  await bank.waitForDeployment();

  // deposit tokens for rewards
  await token.transfer(bank.target, initalDeposit);

  return [bank, token];
}

function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}


describe("Bank", function () {
  
  describe("Deployment", function () {

    it("Deploy contract", async function () {
      const [bank, token] = await getContracts();
      
      const [user1, user2, user3] = await ethers.getSigners();
      
      // minting tokens for users
      await token.mint(user1, ethers.parseEther("1000"));
      await token.mint(user2, ethers.parseEther("4000"));

      // approving transfer for user1 and depositing tokens
      await token.approve(bank.target, ethers.parseEther("1000")); 
      await bank.deposit(ethers.parseEther("1000"));

      // approving transfer for user2 and depositing tokens
      await token.connect(user2).approve(bank.target, ethers.parseEther("4000")); 
      await bank.connect(user2).deposit(ethers.parseEther("4000"));

      // wait for 2T to pass
      await sleep(20000);


      await bank.withdraw();

      // sleep for another T
      await sleep(10000);
      await bank.connect(user2).withdraw();

      // sleep for another T
      await sleep(10000);
      // await bank.bankWithdrawal();
      
      expect(ethers.formatEther(await token.balanceOf(bank.target))).to.equal('500.0');
      expect(ethers.formatEther(await token.balanceOf(user1.address))).to.equal('1040.0');
      expect(ethers.formatEther(await token.balanceOf(user2.address))).to.equal('4460.0');
    }
    );

    it("Checks bank withdrawal", async function() {
      const [bank, token] = await getContracts();
      const [user1, user2, user3] = await ethers.getSigners();
      
      // minting tokens for users
      await token.mint(user1, ethers.parseEther("1000"));
      await token.mint(user2, ethers.parseEther("4000"));

      // approving transfer for user1 and depositing tokens
      await token.approve(bank.target, ethers.parseEther("1000")); 
      await bank.deposit(ethers.parseEther("1000"));

      // approving transfer for user2 and depositing tokens
      await token.connect(user2).approve(bank.target, ethers.parseEther("4000")); 
      await bank.connect(user2).deposit(ethers.parseEther("4000"));

      // wait for 2T to pass
      await sleep(20000);

      await bank.withdraw();

      // sleep for another T
      await sleep(10000);
      await bank.connect(user2).withdraw();

      // sleep for another T
      await sleep(10000);
      await bank.bankWithdrawal();
      
      expect(ethers.formatEther(await token.balanceOf(user1.address))).to.equal('1540.0'); // user1 is bank owner
    });
  });
});
