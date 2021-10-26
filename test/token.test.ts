import "@nomiclabs/hardhat-ethers";
import { ethers } from "hardhat";
import { Signer, BigNumber } from "ethers";
import { expect } from "chai";
import { StableCoinToken } from "../typechain/StableCoinToken";
import { TestVault } from "../typechain/TestVault";
import { solidity } from "ethereum-waffle";
import chai from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

chai.use(solidity);

const BN = BigNumber.from;

describe("Test Token & Vault", function () {
  let owner: SignerWithAddress, account1: SignerWithAddress;

  let price = 4000;

  let token: StableCoinToken;
  let vault: TestVault;

  beforeEach(async () => {
    [owner, account1] = await ethers.getSigners();
    const tokenFactory = await ethers.getContractFactory("StableCoinToken");
    token = (await tokenFactory.deploy()) as StableCoinToken;
    vault = (await (
      await ethers.getContractFactory("TestVault")
    ).deploy(
      token.address,
    )) as TestVault;

    await token.setAdmin(vault.address);
  });
  describe("Token metadata", function () {
    it("Name should be AUD Stablecoin", async () => {
      expect(await token.name()).eq("AUD Stablecoin");
    });
    it("Symbol should be AUDC", async () => {
      expect(await token.symbol()).eq("AUDC");
    });
  });


  describe("Vault getters", function () {
    it("estimateTokenAmount", async () => {
      expect(await vault.estimateTokenAmount(10)).eq(10 * price);
      await vault.deposit(10, {value: 10});
      await vault.setPrice(2000);
      expect(await vault.estimateTokenAmount(10)).eq(0);
    });
    it("estimateCollateralAmount()", async () => {
      await vault.deposit(10, {value: 10});
      expect(await vault.estimateCollateralAmount(price * 5)).eq(5);
      await expect(vault.estimateCollateralAmount(price * 20)).to.be.revertedWith("Repay amount overflow");
      await vault.setPrice(2000);
      expect(await vault.estimateCollateralAmount(price * 5)).eq(10);
    });
  });

  describe("Vault setters", function () {
    it("deposit", async () => {
      expect(await token.balanceOf(owner.address)).eq(0)
      await vault.deposit(10, {value: 10});
      expect(await token.balanceOf(owner.address)).eq(10 * price)
    });
    it("withdraw", async () => {
      await vault.deposit(10, {value: 10});
      expect(await token.balanceOf(owner.address)).eq(10 * price)
      await expect(vault.withdraw(20 * price)).to.be.revertedWith("Repay amount overflow");
      await vault.withdraw(4000);
      expect(await token.balanceOf(owner.address)).eq(9 * price)
      const position = await vault.getVault(owner.address);
      expect(position.debtAmount).eq(9 * price);
      expect(position.collateralAmount).eq(9);
    });
  });
});
