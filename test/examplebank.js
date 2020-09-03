const truffleAssert = require('truffle-assertions');

const ExampleBankContract = artifacts.require("ExampleBank");
const ETHOracleContract = artifacts.require("ETHOracle");
const BaseAMLOracleContract = artifacts.require("BaseAMLOracle");

contract("ExampleBank", async accounts => {
  beforeEach('setup', async () => {
    ExampleBank = await ExampleBankContract.deployed();
    ETHOracle = await ETHOracleContract.deployed();
  });

  context('Example Bank basic functionality', () => {
    it("Donate ether", async () => {
      await ETHOracle.donateETH(ExampleBankContract.address, {from: accounts[0], value: 1000000000000000000});
    });

    it("Begin verification process", async () => {
      let tx = await ExampleBank.verifyMe();
    });

    it("Place AML status as the Oracle Operator", async () => {
      await ETHOracle.setAMLStatus(ExampleBankContract.address, "627306090ABAB3A6E1400E9345BC60C78A8BEF57", web3.utils.fromAscii("123456789"), 99, 0xFF, 1);
    });

    it("Finish the verification process", async () => {
      await ExampleBank.verifyMe();
    });

    it("Depositing", async () => {
      await ExampleBank.deposit({value: 123});
    });

    it("Withdawing", async () => {
      await ExampleBank.deposit({value: 123});
    });
  });
});
