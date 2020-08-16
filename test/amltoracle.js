const truffleAssert = require('truffle-assertions');

const AMLTOracleContract = artifacts.require("AMLTOracle");
const TestToken1Contract = artifacts.require("TestToken1");

contract("AMLTOracle", async accounts => {
  beforeEach('setup', async () => {
    AMLTOracle = await AMLTOracleContract.deployed();
  });


  context('Role Based Access Control (RBAC)', () => {
    it("Check that 'RECOVER_ROLE' is set correctly", async () => {
      let recover = await AMLTOracle.getRoleMember(web3.utils.soliditySha3('RECOVER_ROLE'), 0);
      assert.equal(
        recover.valueOf(),
        accounts[0],
        "Incorrect RECOVER_ROLE address!");
    });

    it("Check that 'ADMIN_ROLE' is set correctly", async () => {
      let admin = await AMLTOracle.getRoleMember(web3.utils.padLeft(0x0), 0);
      assert.equal(
        admin.valueOf(),
        accounts[0],
        "Incorrect ADMIN_ROLE address!");
    });

    it("Remove and restore 'RECOVER_ROLE'", async () => {
      await AMLTOracle.revokeRole(web3.utils.soliditySha3('RECOVER_ROLE'), accounts[0]);
      await truffleAssert.reverts(AMLTOracle.recoverTokens(TestToken1Contract.address), "Recoverable: Caller is not allowed to recover tokens");
      await AMLTOracle.grantRole(web3.utils.soliditySha3('RECOVER_ROLE'), accounts[0]);
      await AMLTOracle.recoverTokens(TestToken1Contract.address);
    });
  });


  context('Token recovery', () => {
    beforeEach('setup', async () => {
      TestToken1 = await TestToken1Contract.deployed();
    });

    it("Transfer and recover AMLT token", async () => {
      await TestToken1.mint();
      await TestToken1.transfer(AMLTOracleContract.address, 1234);
      await AMLTOracle.recoverTokens(TestToken1Contract.address);
    });
  });
});
