// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.7.0; // See README.md for our Solidity version strategy

import "./IBaseAMLOracle.sol";

interface IETHOracle is IBaseAMLOracle {
    /**
     * @dev Donating Ether to an account internally.
     *
     * Account receiving the donation must have AMLOracleAcceptDonationsInETH
     * interface set in the ERC-1820 Registry at
     * 0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24. The interface indicates
     * willingness to accept donations from all AML ETHOracles, not just this
     * particular oracle.
     *
     * On successful execution, {Donated} EVM event is emitted.
     *
     * @param account Account to which account to donate to
     */
    function donateETH(address account) external payable;

    /**
     * @dev Depositing Ether internally for the sender.
     *
     * On successful execution, {Deposited} EVM event is emitted.
     */
    function depositETH() external payable;

    /**
     * @dev Withdraw Ether from sender's internal balance.
     *
     * On successful execution, {Withdrawn} EVM event is emitted.
     *
     * @param amount Amount of ether to be withdrawn
     */
    function withdrawETH(uint256 amount) external;

    /**
     * @dev Fetch an {AMLStatus} as a Client and pay the fee with the supplied
     * ether.
     *
     * See {fetchAMLStatus} for details.
     *
     * On successful execution, {AMLStatusFetched} EVM event is emitted.
     *
     * The fee provided with the call can be thought as the maximum fee:
     * if the actual fee is less than the provided amount, excess amount is
     * deposited for later use (or withdrawal).
     *
     */
    function fetchAMLStatusForETH(string calldata target) external payable returns (bytes32 amlID, uint8 cScore, uint120 flags);
}
