// SPDX-License-Identifier: UNLICENCED
// Placeholder for an Example Decentralized Exchange
pragma solidity ^0.7.0; // See README.md for our Solidity version strategy

import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
import "../contracts/IETHOracle.sol";

contract ExampleBank {
    IETHOracle public oracle;

    IERC1820Registry constant ERC1820REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    constructor(IETHOracle oracle_) {
        oracle = oracle_;
    }

    function verifyMe() public {

    }
}
