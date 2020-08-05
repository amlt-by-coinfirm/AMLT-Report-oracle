// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.7; // Not intended on-chain, can be floating version

import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
//import "truffle/Assert.sol";

contract TestERC1820 {
    IERC1820Registry registry = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    /* function testInterfaceHash() public {
        bytes32 _hash;
        _hash = registry.interfaceHash("blablabla");

        Assert.notEqual(_hash, 0x0, "Hash should not be 0!");
    } */
}
