const truffleAssert = require('truffle-assertions');

const AMLTOracleContract = artifacts.require("AMLTOracle");
const ETHOracleContract = artifacts.require("ETHOracle");
const TestToken1Contract = artifacts.require("TestToken1");

contract("AMLTOracle", async accounts => {
  beforeEach('setup', async () => {
    AMLTOracle = await AMLTOracleContract.deployed();
  });


  context('Role Based Access Control (RBAC)', () => {
    it("Check that 'RECOVER_TOKENS_ROLE' is set correctly", async () => {
      let recover = await AMLTOracle.getRoleMember(web3.utils.soliditySha3('recoverTokens()'), 0);
      assert.equal(
        recover.valueOf(),
        accounts[0],
        "Incorrect RECOVER_TOKENS_ROLE address!");
    });

    it("Check that 'ADMIN_ROLE' is set correctly", async () => {
      let admin = await AMLTOracle.getRoleMember(web3.utils.padLeft(0x0), 0);
      assert.equal(
        admin.valueOf(),
        accounts[0],
        "Incorrect ADMIN_ROLE address!");
    });

    it("Remove and restore 'RECOVER_TOKENS_ROLE'", async () => {
      await AMLTOracle.revokeRole(web3.utils.soliditySha3('recoverTokens()'), accounts[0]);
      await truffleAssert.reverts(
        AMLTOracle.recoverTokens(TestToken1Contract.address),
        "RecoverTokens: the caller is not allowed to recover tokens"
      );
      await AMLTOracle.grantRole(web3.utils.soliditySha3('recoverTokens()'), accounts[0]);
      await truffleAssert.reverts(
        AMLTOracle.recoverTokens(TestToken1Contract.address),
        "RecoverTokens: must recover a positive amount"
      );
    });
  });


  context('Token recovery', () => {
    beforeEach('setup', async () => {
      TestToken1 = await TestToken1Contract.deployed();
    });

    it("Trying to recover 0 amount", async () => {
      await truffleAssert.reverts(
        AMLTOracle.recoverTokens(TestToken1Contract.address),
        "RecoverTokens: must recover a positive amount"
      );
    });

    it("Transfer and recover AMLT token", async () => {
      await TestToken1.mint();
      await TestToken1.transfer(AMLTOracleContract.address, 1234);
      await AMLTOracle.recoverTokens(TestToken1Contract.address);
    });

    it("Trying to recover invalid token", async () => {
      await truffleAssert.reverts(
        AMLTOracle.recoverTokens(accounts[0])
      );
    });

    it("Try to recover deposited AMLT", async () => {
      await TestToken1.mint();
      await TestToken1.approve(AMLTOracleContract.address, 123);
      await AMLTOracle.depositAMLT(123);
      await truffleAssert.reverts(
        AMLTOracle.recoverTokens(TestToken1Contract.address),
        "RecoverTokens: must recover a positive amount"
      );
    });

    it("Try to recover accidentally sent AMLT from ETHOracle", async () => {
      ETHOracle = await ETHOracleContract.deployed();

      await TestToken1.mint();
      await TestToken1.transfer(ETHOracleContract.address, 123);
      await ETHOracle.recoverTokens(TestToken1Contract.address);
    });
  });

  context('Token recovery', () => {
    beforeEach('setup', async () => {
      TestToken1 = await TestToken1Contract.deployed();
    });

    it("Pay fee in AMLT on fetch", async () => {
      await TestToken1.mint();
      await TestToken1.approve(AMLTOracleContract.address, 123);

      await AMLTOracle.setAMLStatus(accounts[0], "someaddress", web3.utils.fromAscii("123456789"), 99, 0xFF, 100);
      await AMLTOracle.fetchAMLStatusForAMLT(123, "someaddress");
    });

    it("Pay fee in AMLT beforehand", async () => {
      await TestToken1.mint();
      await TestToken1.approve(AMLTOracleContract.address, 123);
      await AMLTOracle.depositAMLT(123);
      await AMLTOracle.setAMLStatus(accounts[0], "someaddress", web3.utils.fromAscii("123456789"), 99, 0xFF, 100);
      await AMLTOracle.fetchAMLStatus(123, "someaddress");
    });

    it("Deposit and withdraw AMLT", async () => {
      await TestToken1.mint();
      await TestToken1.approve(AMLTOracleContract.address, 123);
      await AMLTOracle.depositAMLT(123);
      await AMLTOracle.withdrawAMLT(123);
    });
  });
});
