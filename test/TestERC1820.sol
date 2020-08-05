// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.6; // Avoiding regressions by using the oldest safe Solidity

import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
import "truffle/Assert.sol";

contract TestERC1820 {
    IERC1820Registry registry = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    function testInterfaceHash() public {
        bytes32 _hash;
        _hash = registry.interfaceHash("blablabla");

        Assert.notEqual(_hash, 0x0, "Hash should not be 0!");
    }
}
