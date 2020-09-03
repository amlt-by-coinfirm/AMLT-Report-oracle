const ExampleBank = artifacts.require("ExampleBank");
const ETHOracle = artifacts.require("ETHOracle");

module.exports = function(deployer, network, accounts) {
  return deployer.deploy(ExampleBank, ETHOracle.address, {gas: 4000000});
};
