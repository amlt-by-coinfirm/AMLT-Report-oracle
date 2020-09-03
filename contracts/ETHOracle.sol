// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // See README.md for our Solidity version strategy

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

    /// @dev ERC-1820 Interface Hash.
    bytes32 private constant ERC1820INTERFACEHASH = keccak256(abi.encodePacked("AMLOracleAcceptDonationsInETH"));

    /**
     * @dev Empty constructor, only invoking the {BaseAMLOracle-constructor}.
     */
    constructor(address admin, uint256 defaultFee) BaseAMLOracle(admin, defaultFee) RecoverTokens(admin) {

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
    function donateETH(address account) external override payable {
        _donate(msg.sender, account, msg.value);
    }

    /**
     * @dev See {IETHOracle-depositETH}.
     */
    function depositETH() external override payable {
        _deposit(msg.sender, msg.value);
    }

    /**
     * @dev See {IETHOracle-withdrawETH}.
     */
    function withdrawETH(uint256 amount) external override {
        _withdraw(msg.sender, amount);
        msg.sender.sendValue(amount);
    }

    /**
     * @dev See {IETHOracle-fetchAMLStatusForETH} and
     * {IBaseAMLOracle-fetchAMLStatus}.
     */
    function fetchAMLStatusForETH(string calldata target) external override payable returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        _deposit(msg.sender, msg.value);
        return _fetchAMLStatus(msg.sender, target, msg.value);
    }

    /**
     * @dev This function provides the total amount of assets to
     * {BaseAMLOracle} and others interested of Oracle's total asset balance.
     *
     * This differs from the {BaseAMLOracle-_totalDeposits}: unlike _totalDeposits, this
     * value can be forcefully increased, hence it must be higher or equal to
     * _totalDeposits.
     *
     * @return balance Oracle's current total balance
     */
    function getTotalBalance() public view override(BaseAMLOracle, IBaseAMLOracle) returns (uint256 balance) {
        return address(this).balance;
    }

    /**
     * @dev See {IBaseAMLOracle-getInterfaceHash}.
     */
    function getInterfaceHash() public pure override(BaseAMLOracle, IBaseAMLOracle) returns (bytes32 interfaceHash) {
        return ERC1820INTERFACEHASH;
    }
}
