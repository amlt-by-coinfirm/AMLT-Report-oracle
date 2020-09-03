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


/**
 * @title RecoverTokens - a way to recover tokens sent to the contract by
 * accident
 * @author Ville Sundell <development@solarius.fi>
 * @dev
 */
contract RecoverTokens is AccessControl {
    bytes32 public constant RECOVER_TOKENS_ROLE = keccak256("recoverTokens()");

    event RecoveredTokens(IERC20 indexed token, uint256 amount);

    /**
     * @dev The constructor won't do much here: setting the admin to be the
     * recoverer (and role admin).
     *
     * @param admin The address which is set to be the role admin for the
     * recoverer role, and also the first recoverer.
     */
    constructor(address admin) {
        _setupRole(RECOVER_TOKENS_ROLE, admin);
    }

    /**
     * @dev Recover tokens accidentally sent to this contract.
     *
     * @param token The token to recover
     */
    function recoverTokens(IERC20 token) public {
        require(hasRole(RECOVER_TOKENS_ROLE, msg.sender), "RecoverTokens: caller is not allowed to recover tokens");

        uint256 amount = _tokensToBeRecovered(token);
        require(amount > 0, "RecoverTokens: must recover a positive amount");

        try token.transfer(msg.sender, amount) {
            // This is in addition to the event emitted by transfer():
            emit RecoveredTokens(token, amount);
        } catch {
            revert("RecoverTokens: transfer() during token recovery failed");
        }
    }

    /**
     * @dev Function to determine how many tokens to recover.
     *
     * This can be overriden by the parent contract, so tokens which should
     * reside in this contract, would not be recovered.
     *
     * @param token The token to recover
     */
    function _tokensToBeRecovered(IERC20 token) internal view virtual returns (uint256 amountToRecover) {
        return token.balanceOf(address(this));
    }
}
