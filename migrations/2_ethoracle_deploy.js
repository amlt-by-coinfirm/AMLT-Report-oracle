const ETHOracle = artifacts.require("ETHOracle");

module.exports = function(deployer, network, accounts) {
  return deployer.deploy(ETHOracle, accounts[0], 123, {gas: 4000000});
};
