const { ethers } = require("hardhat");
const hre = require("hardhat");

async function defaultFixture() {
    await deployments.fixture();
    const dummyToken = await ethers.getContract('DummyToken');
    const JomEV = await ethers.getContract('JomEV');
    const signers = await ethers.getSigners();
    const deployer = signers[0];
    const account1 = signers[1];
    const account2 = signers[2];
    const account3 = signers[3];
    
    return {
        dummyToken,
        JomEV,
        deployer,
        account1,
        account2,
        account3
    }
}

module.exports = {
    defaultFixture
}