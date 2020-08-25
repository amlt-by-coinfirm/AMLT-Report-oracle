// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import "openzeppelin-solidity/contracts/utils/Address.sol";
import "./BaseAMLOracle.sol";
import "./IETHOracle.sol";
import "./RecoverTokens.sol";

/**
 * @title ETHOracle - AML Oracle with Ether payments, inherits {BaseAMLOracle}
 * @author Ville Sundell <development@solarius.fi>
 * @dev This AML Oracle works with Ether, and is based on {BaseAMLOracle}.
 */
contract ETHOracle is RecoverTokens, BaseAMLOracle, IETHOracle {
    using Address for address payable;

    /**
     * @dev Empty constructor, only invoking the {BaseAMLOracle-constructor}.
     */
    constructor(address admin, uint256 defaultFee) BaseAMLOracle(admin, defaultFee) {

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
     * @dev See {IETHOracle-donateETH}.
     */
    function donateETH(address account) external payable {
        _donate(msg.sender, account, msg.value);
    }

    /**
     * @dev See {IETHOracle-depositETH}.
     */
    function depositETH() external payable {
        _deposit(msg.sender, msg.value);
    }

    /**
     * @dev See {IETHOracle-withdrawETH}.
     */
    function withdrawETH(uint256 amount) external {
        _withdraw(msg.sender, amount);
        msg.sender.sendValue(amount);
    }

    /**
     * @dev See {IETHOracle-fetchAMLStatusForETH} and
     * {IBaseAMLOracle-fetchAMLStatus}.
     */
    function fetchAMLStatusForETH(string calldata target) external payable returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        _deposit(msg.sender, msg.value);
        return _fetchAMLStatus(msg.sender, target);
    }

    function _getTotalBalance() internal virtual override view returns (uint256 balance) {
        return address(this).balance;
    }
}
