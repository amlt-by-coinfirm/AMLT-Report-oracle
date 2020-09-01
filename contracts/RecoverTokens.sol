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

    function recoverTokens(IERC20 token, uint256 amount) public {
        require(hasRole(RECOVER_TOKENS_ROLE, msg.sender), "RecoverTokens: caller is not allowed to recover tokens");
        require(amount > 0, "RecoverTokens: must recover a positive amount");

        amount = _tokensToBeRecovered(token, amount);

        try token.transfer(msg.sender, amount) {
            emit RecoveredTokens(token, amount); // This is in addition to the event emitted by transfer()
        } catch {
            revert("RecoverTokens: transfer() during token recovery failed");
        }
    }

    function _tokensToBeRecovered(IERC20, uint256 amount) internal view virtual returns (uint256 amountToRecover) {
        return amount;
    }
}
