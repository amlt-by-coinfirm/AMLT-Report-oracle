// SPDX-License-Identifier: UNLICENCED
// Placeholder for an Example Decentralized Exchange
pragma solidity ^0.7.0; // See README.md for our Solidity version strategy

import "../contracts/IETHOracle.sol";

contract ExampleBank {
    IETHOracle public oracle;

    constructor(IETHOracle oracle_) {
        oracle = oracle_;
    }

    function verifyMe() public {

    }
}
