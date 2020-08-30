// This is for hitting and testing all the require()s we use
const truffleAssert = require('truffle-assertions');

const ETHOracleContract = artifacts.require("ETHOracle");

contract("ETHOracle", async accounts => {
  beforeEach('setup', async () => {
    ETHOracle = await ETHOracleContract.deployed();
  });


  context("Hitting the rest of our require()s", () => {

    it("Testing maxFee on fetch", async () => {
      await ETHOracle.setAMLStatus(accounts[0], "realaddress", web3.utils.fromAscii("123456789"), 99, 0x1, 123),
      await truffleAssert.reverts(
        ETHOracle.fetchAMLStatus(100, "realaddress"),
        "BaseAMLOracle: required fee is greater than the maximum specified fee"
      );
    });

    it("Try to get AML Status query fee", async () => {
      await truffleAssert.reverts(
        ETHOracle.getAMLStatusFee("0x0000000000000000000000000000000000000000", "bogusaddress"),
        "BaseAMLOracle: client must not be 0x0"
      );
    });

    it("Try to get AML Status query timestamp", async () => {
      await truffleAssert.reverts(
        ETHOracle.getAMLStatusTimestamp("0x0000000000000000000000000000000000000000", "bogusaddress"),
        "BaseAMLOracle: client must not be 0x0"
      );
    });

    it("Try to get non-existent AML Status Metadata", async () => {
      await truffleAssert.reverts(
        ETHOracle.getAMLStatusMetadata("bogusaddress"),
        "BaseAMLOracle: no such AML Status"
      );
    });

    it("Try to get AML Status Metadata as 0x0", async () => {
      await truffleAssert.reverts(
        ETHOracle.methods["getAMLStatusMetadata(address,string)"]("0x0000000000000000000000000000000000000000", "bogusaddress"),
        "BaseAMLOracle: client must not be 0x0"
      );
    });

    it("Delete AML Status for 0x0", async () => {
      await truffleAssert.reverts(
        ETHOracle.deleteAMLStatus("0x0000000000000000000000000000000000000000", "bogusaddress"),
        "BaseAMLOracle: cannot delete AML status for 0x0"
      );
    });

    it("Set AML Status for 0x0", async () => {
      await truffleAssert.reverts(
        ETHOracle.setAMLStatus("0x0000000000000000000000000000000000000000", "bogusaddress", web3.utils.fromAscii("123456789"), 99, 0x1, 123),
        "BaseAMLOracle: cannot set AML status for 0x0"
      );
    });

    it("Use cScore above 99", async () => {
      await truffleAssert.reverts(
        ETHOracle.setAMLStatus(accounts[0], "bogusaddress", web3.utils.fromAscii("123456789"), 123, 0x1, 123),
        "BaseAMLOracle: The cScore must be between 0 and 99"
      );
    });

    it("Notify 0x0", async () => {
      await truffleAssert.reverts(
        ETHOracle.notify("0x0000000000000000000000000000000000000000", "bogusmessage"),
        "BaseAMLOracle: client must not be 0x0"
      );
    });

    it("Set fee account to 0x0", async () => {
      await truffleAssert.reverts(
        ETHOracle.setFeeAccount("0x0000000000000000000000000000000000000000"),
        "BaseAMLOracle: the fee account must not be 0x0"
      );
    });

    it("Withdraw 0 amount", async () => {
      await truffleAssert.reverts(
        ETHOracle.withdrawETH(0),
        "BaseAMLOracle: amount to withdraw must be greater than 0"
      );
    });

    it("Withdraw 0 amount", async () => {
      await truffleAssert.reverts(
        ETHOracle.withdrawETH(0),
        "BaseAMLOracle: amount to withdraw must be greater than 0"
      );
    });

    it("Deposit 0 amount", async () => {
      await truffleAssert.reverts(
        ETHOracle.sendTransaction({from: accounts[0], value: 0}),
        "BaseAMLOracle: amount to deposit must be greater than 0"
      );
    });
  });


  context('Trying to access privileged functions as a non-privileged user', () => {
    it("setDefaultFee()", async () => {
      await truffleAssert.reverts(
        ETHOracle.setDefaultFee(0, {from:accounts[1]}),
        "BaseAMLOracle: caller is not allowed to set the default fee"
      );
    });

    it("setFeeAccount()", async () => {
      await truffleAssert.reverts(
        ETHOracle.setFeeAccount("0x0000000000000000000000000000000000000000", {from:accounts[1]}),
        "BaseAMLOracle: caller is not allowed to set the fee account"
      );
    });

    it("notify()", async () => {
      await truffleAssert.reverts(
        ETHOracle.notify(accounts[0], "bogus message", {from:accounts[1]}),
        "BaseAMLOracle: caller is not allowed to notify the clients"
      );
    });

    it("setAMLStatus()", async () => {
      await truffleAssert.reverts(
        ETHOracle.setAMLStatus(accounts[0], "bogusaddress", web3.utils.fromAscii("123456789"), 11, 0x1, 123, {from:accounts[1]}),
        "BaseAMLOracle: caller is not allowed to set AML statuses"
      );
    });

    it("deleteAMLStatus()", async () => {
      await truffleAssert.reverts(
        ETHOracle.deleteAMLStatus(accounts[0], "bogusaddress", {from:accounts[1]}),
        "BaseAMLOracle: caller is not allowed to delete AML statuses"
      );
    });

    it("recoverTokens()", async () => {
      await truffleAssert.reverts(
        ETHOracle.recoverTokens(accounts[0], {from:accounts[1]}),
        "RecoverTokens: caller is not allowed to recover tokens"
      );
    });
  });
});
