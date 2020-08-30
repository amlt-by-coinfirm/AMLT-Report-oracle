const AMLTOracle = artifacts.require("AMLTOracle");
const TestToken1 = artifacts.require("TestToken1");

module.exports = function(deployer, network, accounts) {
  return deployer.deploy(AMLTOracle, accounts[0], 123, TestToken1.address, {gas: 4500000});
};
