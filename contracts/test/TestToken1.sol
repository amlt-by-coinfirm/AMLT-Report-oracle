// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.7; // Not intended on-chain, can be floating version
// This is ONLY FOR TESTING.
// NO NEED TO AUDIT
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract TestToken1 is ERC20 {
    constructor() ERC20("TestToken", "TEST") {
        _mint(msg.sender, 100000000000000000000000000);
    }

    function mint() public {
        _mint(msg.sender, 100000000000000000000000000);
    }
}
