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

const main = async () => {
  const {deployerAddr, governorAddr} = await getNamedAccounts();
  const sDeployer = await ethers.provider.getSigner(deployerAddr);
  const sGovernor = await ethers.provider.getSigner(governorAddr);
  const cJomEV = await ethers.getContract("JomEV");
  const cDummyToken = await ethers.getContract("DummyToken");

  await withConfirmation(cJomEV.connect(sDeployer).joinAsUser());
  await withConfirmation(cJomEV.connect(sDeployer).joinAsProvider());
  await withConfirmation(cDummyToken.connect(sDeployer).faucet());
  await withConfirmation(cDummyToken.connect(sDeployer).approve(cJomEV.address,parseUnits("0.0005").mul(24).mul(8)));
  await withConfirmation(cJomEV.connect(sDeployer).addStation(parseUnits("0.0005"),"Damansara",cDummyToken.address));

  //add new user to book from that account
  await withConfirmation(cJomEV.connect(sGovernor).joinAsUser())
  await withConfirmation(cDummyToken.connect(sGovernor).faucet());
  await withConfirmation(cDummyToken.connect(sGovernor).approve(cJomEV.address,parseUnits("0.0005")));
  await withConfirmation(cJomEV.connect(sGovernor).bookStation(1,1,"0x000001",cDummyToken.address));

  const currState = await cJomEV.getStation(1);
  console.log(currState);

};

main.id = "001_core";
main.skip = () => !isScript;
module.exports = main;
