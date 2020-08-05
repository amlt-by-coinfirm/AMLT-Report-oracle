// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.6; // Avoiding regressions by using the oldest safe Solidity
// This is ONLY FOR TESTING.
// NO NEED TO AUDIT
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract TestToken1 is ERC20 {
    constructor() ERC20("TestToken", "TEST") public {
        _mint(msg.sender, 100000000000000000000000000);
    }

    function mint() public {
        _mint(msg.sender, 100000000000000000000000000);
    }
}
