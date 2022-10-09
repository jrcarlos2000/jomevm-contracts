const { ethers } = require("hardhat");
const hre = require("hardhat");

async function defaultFixture() {
	await deployments.fixture();
	const dummyToken = await ethers.getContract('DummyToken');
	const evToken = await ethers.getContract('EVToken');
	const JomEV = await ethers.getContract('JomEV');
	const Vault = await ethers.getContract('Vault');
	const signers = await ethers.getSigners();
	const deployer = signers[0];
	const account1 = signers[1];
	const account2 = signers[2];
	const account3 = signers[3];
	
	return {
		dummyToken,
		evToken,
		JomEV,
		Vault,
		deployer,
		account1,
		account2,
		account3
	}
}

module.exports = {
	defaultFixture
}