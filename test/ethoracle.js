const truffleAssert = require('truffle-assertions');

const ETHOracleContract = artifacts.require("ETHOracle");

contract("ETHOracle", async accounts => {
  beforeEach('setup', async () => {
    ETHOracle = await ETHOracleContract.deployed();
  });


  context('Basic AML Oracle functionality (Smoke Test)', () => {
    it("Deposit funds", async () => {
      await ETHOracle.sendTransaction({from: accounts[0], value: 1000000000000000000});
      let balance = await ETHOracle.balanceOf(accounts[0]);
      assert.notEqual(
        balance.valueOf(),
        0,
        "Balance should not be 0!");
    });

    it("Set defaultFee", async () => {
      let tx = await ETHOracle.setDefaultFee(100);
      truffleAssert.eventEmitted(tx, 'DefaultFeeSet', (ev) => {
        return ev.oldDefaultFee == 0 && ev.newDefaultFee == 100;
      });

      let result = await ETHOracle.getDefaultFee.call();
      assert.equal(result.valueOf(), 100, "defaultFee not set correctly!");
    });

    it("Set feeAccount", async () => {
      let tx = await ETHOracle.setFeeAccount(accounts[1]);
      truffleAssert.eventEmitted(tx, 'FeeAccountSet', (ev) => {
        return ev.oldFeeAccount == accounts[0] && ev.newFeeAccount == accounts[1];
      });

      let result = await ETHOracle.getFeeAccount.call();
      assert.equal(result.valueOf(), accounts[1], "feeAccount not set correctly!");
    });

    it("Ask AML Status", async () => {
      let tx = await ETHOracle.askAMLStatus(100, "someaddress");
      truffleAssert.eventEmitted(tx, 'AMLStatusAsked', (ev) => {
        return ev.client == accounts[0] && ev.maxFee == 100 && ev.target == "someaddress";
      });
    });

    it("Set AML Status", async () => {
      let tx = await ETHOracle.setAMLStatus(accounts[0], "someaddress", web3.utils.fromAscii("123456789"), 99, 0xFF, 100);
      truffleAssert.eventEmitted(tx, 'AMLStatusSet', (ev) => {
        return ev.client == accounts[0] && ev.target == "someaddress";
      });
    });

    it("Get AML Status Metadata", async () => {
      let result = await ETHOracle.getAMLStatusMetadata(accounts[0], "someaddress");
      const {0: timestamp, 1: fee} = result;

      assert.notEqual(timestamp, 0, "Timestamp can't be 0!");
      assert.equal(fee, 100, "Fee is incorrect, should be 100!");
    });

    it("Fetch AML Status", async () => {
      let result = await ETHOracle.fetchAMLStatus.call("someaddress");
      const {0: amlID, 1: cScore, 2: flags} = result;

      assert.notEqual(amlID, 0, "AML ID incorrect, should not be 0!");
      assert.equal(cScore, 99, "cScore not 99!");
      assert.equal(flags, 0xFF, "Flags should be 0xFF");

      let tx = await ETHOracle.fetchAMLStatus("someaddress");

      truffleAssert.eventEmitted(tx, 'AMLStatusFetched', (ev) => {
        return ev.client == accounts[0] && ev.target == "someaddress";
      });
    });

    it("Withdraw funds", async () => {
      let result = await ETHOracle.withdrawETH(100);

      truffleAssert.eventEmitted(result, 'Withdrawn', (ev) => {
        return ev.account == accounts[0] && ev.amount == 100;
      });
    });

    it("Withdraw fees", async () => {
      let result = await ETHOracle.withdrawETH(100, {from: accounts[1]});

      truffleAssert.eventEmitted(result, 'Withdrawn', (ev) => {
        return ev.account == accounts[1] && ev.amount == 100;
      });
    });


  });
});
