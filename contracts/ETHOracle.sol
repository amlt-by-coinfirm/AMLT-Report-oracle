// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import 'openzeppelin-solidity/contracts/utils/Address.sol';
import "./BaseAMLOracle.sol";
import './RecoverTokens.sol';

contract ETHOracle is RecoverTokens, BaseAMLOracle {
    using Address for address payable;

    constructor(address admin) BaseAMLOracle(admin) {

    }

    /**
     * @dev Receiving and depositing Ether.
     *
     * On successful execution, {Deposited} EVM event is emitted.
     */
    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    /**
     * @dev Donating Ether to an account internally.
     *
     * On successful execution, {Donated} EVM event is emitted.
     *
     * @param account Account to which account to donate to
     */
    function donateETH(address account) external payable {
        _donate(msg.sender, account, msg.value);
    }

    /**
     * @dev Depositing Ether internally for the sender.
     *
     * On successful execution, {Deposited} EVM event is emitted.
     */
    function depositETH() external payable {
        _deposit(msg.sender, msg.value);
    }

    /**
     * @dev Withdraw Ether from sender's internal balance.
     *
     * On successful execution, {Withdrawn} EVM event is emitted.
     *
     * @param amount Amount of ether to be withdrawn
     */
    function withdrawETH(uint256 amount) external {
        _withdraw(msg.sender, amount);
        msg.sender.sendValue(amount);
    }

    /**
     * @dev Fetch an {AMLStatus} as a Client and pay the fee with the supplied
     * ether.
     *
     * See {fetchAMLStatus} for details.
     *
     * On successful execution, {AMLStatusFetched} EVM event is emitted.
     *
     */
    function fetchAMLStatusForETH(string calldata target) external payable returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        _deposit(msg.sender, msg.value);
        return _fetchAMLStatus(msg.sender, target);
    }

    function _getTotalBalance() internal virtual override view returns (uint256 balance) {
        return address(this).balance;
    }
}
