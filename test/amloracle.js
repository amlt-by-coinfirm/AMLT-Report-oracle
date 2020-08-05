const truffleAssert = require('truffle-assertions');

const AMLOracleContract = artifacts.require("AMLOracle");
const TestToken1Contract = artifacts.require("TestToken1");

contract("AMLOracle", async accounts => {
  beforeEach('setup', async () => {
    AMLOracle = await AMLOracleContract.deployed();
  });


  context('Role Based Access Control (RBAC)', () => {
    it("Check that 'RECOVER_ROLE' is set correctly", async () => {
      let recover = await AMLOracle.getRoleMember(web3.utils.soliditySha3('RECOVER_ROLE'), 0);
      assert.equal(
        recover.valueOf(),
        accounts[0],
        "Incorrect RECOVER_ROLE address!");
    });

    it("Check that 'ADMIN_ROLE' is set correctly", async () => {
      let admin = await AMLOracle.getRoleMember(web3.utils.padLeft(0x0), 0);
      assert.equal(
        admin.valueOf(),
        accounts[0],
        "Incorrect ADMIN_ROLE address!");
    });

    it("Remove and restore 'RECOVER_ROLE'", async () => {
      await AMLOracle.revokeRole(web3.utils.soliditySha3('RECOVER_ROLE'), accounts[0]);
      await truffleAssert.reverts(AMLOracle.recoverTokens(TestToken1Contract.address), "Caller is not allowed to recover tokens!");
      await AMLOracle.grantRole(web3.utils.soliditySha3('RECOVER_ROLE'), accounts[0]);
      await AMLOracle.recoverTokens(TestToken1Contract.address);
    });
  });


  context('Token recovery', () => {
    beforeEach('setup', async () => {
      TestToken1 = await TestToken1Contract.deployed();
    });

    it("Transfer and recover AMLT token", async () => {
      await TestToken1.mint();
      await TestToken1.transfer(AMLOracleContract.address, 1234);
      await AMLOracle.recoverTokens(TestToken1Contract.address);
    });
  });
});
