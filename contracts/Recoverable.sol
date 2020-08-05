/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 * Original: https://github.com/TokenMarketNet/smart-contracts/blob/master/contracts/Recoverable.sol
 * SPDX-License-Identifier: Apache-2.0
 */

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.6.10; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import "openzeppelin-solidity/contracts/access/AccessControl.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract Recoverable is AccessControl {
    bytes32 public constant RECOVER_ROLE = keccak256("RECOVER_ROLE");

    constructor() public {
        _setupRole(RECOVER_ROLE, msg.sender);
    }

    /// @dev This will be invoked by the owner, when owner wants to rescue tokens
    /// @param token Token which will we rescue to the owner from the contract
    function recoverTokens(IERC20 token) public {
        require(hasRole(RECOVER_ROLE, msg.sender), "Caller is not allowed to recover tokens!");
        token.transfer(msg.sender, tokensToBeReturned(token));
    }

    /// @dev Interface function, can be overwritten by the superclass
    /// @param token Token which balance we will check and return
    /// @return The amount of tokens (in smallest denominator) the contract owns
    function tokensToBeReturned(IERC20 token) public view virtual returns (uint256) {
        return token.balanceOf(address(this));
    }
}
