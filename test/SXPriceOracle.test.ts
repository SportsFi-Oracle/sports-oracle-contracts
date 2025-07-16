const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SXPriceOracle", function () {
    it("Should update the price correctly by the asset", async function () {
        const SXPriceOracle = await ethers.getContractFactory("SXPriceOracle");
        const sxPriceOracle = await SXPriceOracle.deploy();
        await sxPriceOracle.deployed();

        await sxPriceOracle.updatePrice("BTC", 10000);
        expect((await sxPriceOracle.getPrice("BTC")).toString()).to.equal("10000");

        await sxPriceOracle.updatePrice("ETH", 300);
        expect((await sxPriceOracle.getPrice("ETH")).toString()).to.equal("300");

        await sxPriceOracle.updatePrice("USDT", 1);
        expect((await sxPriceOracle.getPrice("USDT")).toString()).to.equal("1");

        await sxPriceOracle.updatePrice("USDC", 1);
        expect((await sxPriceOracle.getPrice("USDC")).toString()).to.equal("1");

        await sxPriceOracle.updatePrice("SX", ethers.utils.parseUnits("0.08", 18));
        expect((await sxPriceOracle.getPrice("SX")).toString()).to.equal(
            ethers.utils.parseUnits("0.08", 18).toString()
        );
    });
});
