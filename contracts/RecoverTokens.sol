/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 * Original: https://github.com/TokenMarketNet/smart-contracts/blob/master/contracts/Recoverable.sol
 * SPDX-License-Identifier: Apache-2.0
 */

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import "openzeppelin-solidity/contracts/access/AccessControl.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract RecoverTokens is AccessControl {
    bytes32 public constant RECOVER_TOKENS_ROLE = keccak256("recoverTokens()");

    event RecoveredTokens(IERC20 indexed token, uint256 amount);

    constructor() {
        _setupRole(RECOVER_TOKENS_ROLE, msg.sender);
    }

    function recoverTokens(IERC20 token) public {
        require(hasRole(RECOVER_TOKENS_ROLE, msg.sender), "RecoverTokens: Caller is not allowed to recover tokens");

        uint256 amount = _tokensToBeRecovered(token);

        try token.transfer(msg.sender, amount) {
            emit RecoveredTokens(token, amount); // This is in addition to the event emitted by transfer()
        } catch {
            revert("RecoverTokens: transfer() during token recovery failed");
        }
    }

    function _getTokenBalance(IERC20 token) internal view virtual returns (uint256 amount) {
        try token.balanceOf(address(this)) returns (uint256 balance) {
            return balance;
        } catch {
            revert("RecoverTokens: could not query the token balance");
        }
    }

    function _tokensToBeRecovered(IERC20 token) internal view virtual returns (uint256 amount) {
        return _getTokenBalance(token);
    }
}
