const TestToken1 = artifacts.require("TestToken1");

module.exports = function(deployer, network, accounts) {
  if (network != "rinkeby") {
    deployer.deploy(TestToken1);
  }
};

//   if (network != "rinkeby") {
//    deployer.deploy(TestToken2);
//    deployer.deploy(TestToken1).then(function(){
//      return deployer.deploy(AMLOracle, TestToken1.address);
//    });
//  } else {
//    deployer.deploy(AMLOracle, accounts[0]);
//  }
