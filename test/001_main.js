const { expect } = require("chai");
const { ethers } = require("hardhat");
const {defaultFixture} = require('./_fixture');
const {loadFixture} = require('../utils/helpers');
const { parseUnits, defaultAbiCoder, hexStripZeros } = require("ethers/lib/utils");

async function approve(fromSigner, to , token, amount) {
  await token.connect(fromSigner).faucet();
  await token.connect(fromSigner).approve(to,amount);
}
describe("Main Test Suite", async () => {
  describe("Dummy Token", async ()=>{
    it("should mint for any user", async () => {
      const { dummyToken, deployer, account1 } = await loadFixture(defaultFixture);
      const balance = await dummyToken.balanceOf(deployer.address);
      expect(balance).to.equal(parseUnits("1000"));
      await dummyToken.connect(account1).faucet();
      expect(await dummyToken.balanceOf(account1.address)).to.equal(parseUnits("1000"));
    });
  })
  describe("JomEV Core", async () => {
   it("should add users, add provider and create station", async () => {
      const {JomEV, deployer, dummyToken,  account1, account2} = await loadFixture(defaultFixture);
      await JomEV.connect(deployer).joinAsUser();
      await JomEV.connect(deployer).joinAsProvider();
      await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005").mul(24).mul(7).mul(2))
      await JomEV.connect(deployer).addChargingPoint(parseUnits("0.000005"),"Damansara",dummyToken.address,2);
   })
   it("can book station", async ()=> {
      const {JomEV,dummyToken, deployer, account1, account2} = await loadFixture(defaultFixture);
      await JomEV.connect(deployer).joinAsUser();
      await JomEV.connect(deployer).joinAsProvider();
      await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005").mul(24).mul(7).mul(2))
      await JomEV.connect(deployer).addChargingPoint(parseUnits("0.000005"),"Damansara",dummyToken.address,2);      await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005"));
      await JomEV.connect(deployer).bookStation(1,1,1,"0x101000",dummyToken.address);

      //booking 2
      await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005").mul(24).mul(7).mul(2))
      await JomEV.connect(deployer).bookStation(1,2,1,"0x101000",dummyToken.address);
   })
   it("booking details are right", async ()=> {
    const {JomEV, deployer, dummyToken, account1, account2} = await loadFixture(defaultFixture);
    await JomEV.connect(deployer).joinAsUser();
    await JomEV.connect(deployer).joinAsProvider();
    await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005").mul(24).mul(7).mul(2))
    await JomEV.connect(deployer).addChargingPoint(parseUnits("0.000005"),"Damansara",dummyToken.address,2);      await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005"));
    //six values must be filled
    // 0001 1000 1000 0001 0000 0000
    // 0000 0010 0000 0100 0000 1000
    //result
    // 0001 1010 1000 0101 0000 1000
    const input1 = "0x188100";
    const input2 = "0x020408";
    const output = "0x1A8508";
    await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005"));
    await JomEV.connect(deployer).bookStation(1,1,1,input1,dummyToken.address);
    await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005"));
    await JomEV.connect(deployer).bookStation(1,1,1,input2,dummyToken.address);

    const stationData = await JomEV.getStation(1);
    expect(stationData.availability[1].toLowerCase()).to.equal(output.toLowerCase());
 })
   it("can desactivate stations", async () => {
    const {JomEV, dummyToken, deployer, account1, account2} = await loadFixture(defaultFixture);
    await JomEV.connect(account1).joinAsUser();
    await JomEV.connect(deployer).joinAsUser();
    await JomEV.connect(deployer).joinAsProvider();
    await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005").mul(24).mul(7).mul(2))
    await JomEV.connect(deployer).addChargingPoint(parseUnits("0.000005"),"Damansara",dummyToken.address,2);      await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005"));
    await JomEV.connect(deployer).desactivateConnector(1,1);
    const stationData = await JomEV.getStation(1);
    expect(stationData.isActive).to.equal(false);
   })

//    it("test timestamp onChain", async ()=>{
//     const {JomEV, deployer, account1, account2} = await loadFixture(defaultFixture);
//     const currTime = new Date();
//     const onChainTime = await JomEV.getBlockTimestamp();
//    })

//    it("test day timestamp", async ()=>{
//     const {JomEV, dummyToken, deployer, account1, account2} = await loadFixture(defaultFixture);
//     await JomEV.connect(deployer).joinAsUser();
//     await JomEV.connect(account1).joinAsUser();
//     await JomEV.connect(deployer).joinAsProvider();
//     await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005")*24*8)
//     await  JomEV.connect(deployer).addStation(parseUnits("0.000005"),"Petaling Jaya",dummyToken.address);

//     for(let i = 1; i<6 ; i++) {
//       await ethers.provider.send("evm_increaseTime", [86405]);
//       await approve(account1,JomEV.address,dummyToken,parseUnits("0.000005"));
//       await JomEV.connect(account1).bookStation(1,1,"0x800000",dummyToken.address);
//       let currStationData = await JomEV.getStation(1);
//       expect(currStationData.availability[1+i%7]).to.equal("0x800000",dummyToken.address);
//     }
//    })

   //put fail tests below
   it("cannot add station if not user", async ()=>{
    const {JomEV, dummyToken, deployer, account1, account2} = await loadFixture(defaultFixture);
    await JomEV.connect(account1).joinAsUser();
    await expect(JomEV.connect(deployer).joinAsProvider()).to.be.revertedWith("This Feature is only for users");
   })
   it("cannot book station if time overlaps", async ()=>{
    const {JomEV, dummyToken, deployer, account1, account2} = await loadFixture(defaultFixture);
    await JomEV.connect(account1).joinAsUser();
    await JomEV.connect(deployer).joinAsUser();
    await JomEV.connect(deployer).joinAsProvider();
    await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005").mul(24).mul(7).mul(2))
    await JomEV.connect(deployer).addChargingPoint(parseUnits("0.000005"),"Damansara",dummyToken.address,2);      await approve(deployer,JomEV.address,dummyToken,parseUnits("0.000005"));
    await JomEV.connect(deployer).bookStation(1,1,1,"0x101000",dummyToken.address);
    
    // 0001 1000 1000 0001 0000 0000
    // 0001 0000 0000 0000 0000 0000
    await approve(account1,JomEV.address,dummyToken,parseUnits("0.000005"));
    await expect(JomEV.connect(account1).bookStation(1,1,1,"0x100000",dummyToken.address)).to.be.revertedWith("new schedule overlaps");
   })
  })
});