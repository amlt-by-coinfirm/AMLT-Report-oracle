const AMLOracle = artifacts.require("AMLOracle");

module.exports = function(deployer, network, accounts) {
  return deployer.deploy(AMLOracle);
};
