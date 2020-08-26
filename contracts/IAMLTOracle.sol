// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.7.0; // See README.md for our Solidity version strategy

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./IBaseAMLOracle.sol";

interface IAMLTOracle is IBaseAMLOracle {
    /**
     * @dev Donating AMLT to an account internally.
     *
     * Before calling this function, the account must have called {AMLToken}'s
     * {IERC20-approve} approving this Oracle to access their tokens.
     *
     * On successful execution, {Donated} EVM event is emitted.
     *
     * @param account Client for which the tokens will be donated to internally
     * @param amount Amount of tokens to be transferred from `account` to the
     * Oracle
     */
    function donateAMLT(address account, uint256 amount) external;

    /**
     * @dev Deposit AMLT to an account internally.
     *
     * This function transfers `amount` of tokens from the caller to caller's
     * internal balance for paying fees in the future.
     *
     * Before calling this function, the account must have called {AMLToken}'s
     * {IERC20-approve} approving this Oracle to access their tokens.
     *
     * On successful execution, {Deposited} EVM event is emitted.
     *
     * @param amount Amount of tokens to be transferred from `account` to the
     * Oracle
     */
    function depositAMLT(uint256 amount) external;

    /**
     * @dev Withdraw AMLT tokens from caller's internal balance.
     *
     * Will withdraw `amount` of AMLT tokens from caller's internal balance
     * to the caller themselves using {IERC20-transfer}.
     *
     * On successful execution, {Withdrawn} EVM event is emitted.
     *
     * @param amount Amount of tokens to withdraw from caller's internal
     * balance
     */
    function withdrawAMLT(uint256 amount) external;

    /**
     * @dev Fetch an {AMLStatus} as a Client and pay the fee with the supplied
     * ether.
     *
     * See {fetchAMLStatus} for details.
     *
     * On successful execution, {AMLStatusFetched} EVM event is emitted.
     *
     *
     */
    function fetchAMLStatusForAMLT(string calldata target) external returns (bytes32 amlID, uint8 cScore, uint120 flags);
}
