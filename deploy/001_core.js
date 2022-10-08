require("hardhat");
const { utils } = require("ethers");
const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { parseUnits, formatUnits } = require("ethers").utils;
const { getTokenAddresses, isFork, isScript } = require("../utils/helpers");
const {
  deployWithConfirmation,
  withConfirmation,
  log
} = require("../utils/deploy");

const deployDummyToken = async () => {
  const { deployerAddr, governorAddr } = await getNamedAccounts();
  await deployWithConfirmation("DummyToken",["USD Tether","USDT"]);
};

const deployEVToken= async()=>{
  const { deployerAddr, governorAddr } = await getNamedAccounts();
  await deployWithConfirmation("EVToken",["EV Token","EVT"]);
};

const deployJomEV = async () => {

  const {deployerAddr} = await getNamedAccounts();
  const sDeployer = await ethers.provider.getSigner(deployerAddr);
  await deployWithConfirmation("JomEV");
  const cJomEV = await ethers.getContract("JomEV");
  const cDummyToken = await ethers.getContract("DummyToken");
  await cJomEV.connect(sDeployer).addAcceptedPayment(cDummyToken.address);

};

const deployVault = async () => {

  const {deployerAddr} = await getNamedAccounts();
  const sDeployer = await ethers.provider.getSigner(deployerAddr);
  await deployWithConfirmation("Vault");
  const cVault = await ethers.getContract("Vault");
  const cDummyToken = await ethers.getContract("DummyToken");
  const cEVToken = await ethers.getContract("EVToken");
  const cJomEV = await ethers.getContract("JomEV");
  await cVault.connect(sDeployer).setEVTokenAddress(cEVToken.address);
  await cJomEV.connect(sDeployer).setVault(cVault.address);

};

const main = async () => {
  await deployDummyToken();
  await deployEVToken();
  await deployJomEV();
  await deployVault();
};

main.id = "001_core";
main.skip = () => isFork || isScript;
module.exports = main;
