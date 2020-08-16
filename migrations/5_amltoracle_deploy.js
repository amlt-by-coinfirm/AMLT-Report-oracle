const AMLTOracle = artifacts.require("AMLTOracle");
const TestToken1 = artifacts.require("TestToken1");

module.exports = function(deployer, network, accounts) {
  return deployer.deploy(AMLTOracle, accounts[0], TestToken1.address);
};
