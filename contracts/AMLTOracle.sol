// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.7.0; // See README.md's section "Solidity version"

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./BaseAMLOracle.sol";
import "./IAMLTOracle.sol";
import "./RecoverTokens.sol";


/**
 * @title AMLTOracle - AML Oracle with AMLT token payments, inherits
 * {BaseAMLOracle}
 * @author Ville Sundell <development@solarius.fi>
 * @dev This AML Oracle works with AMLT tokens, and is based on
 * {BaseAMLOracle}.
 *
 * This is specific to AMLT token contract, and hence is not a generic
 * ERC-20 implementation. That's why we use the try/catch pattern only on
 * occasions where we know the token contract could revert().
 *
 * AMLT token contract is a trusted contract, so following
 * Checks-Effects-Interactions pattern here would overly complicate things.
 */
contract AMLTOracle is RecoverTokens, BaseAMLOracle, IAMLTOracle {
    using SafeMath for uint256; // Applicable only for uint256

    /// @dev ERC-1820 Interface Hash.
    bytes32 private constant ERC1820INTERFACEHASH = keccak256(abi.encodePacked("AMLOracleAcceptDonationsInAMLT"));

    /**
     * @dev AMLT token contract address resides here. It's not hardcoded
     * so the same code could be run on many different networks (mainly for
     * testing purposes).
     */
    IERC20 private _amlToken;

    /**
     * @dev This constructor only sets the {_amlToken}, other initialization
     * tasks are done in {BaseAMLOracle}'s constructor.
     */
    constructor(address admin, uint256 defaultFee, IERC20 amlToken_) BaseAMLOracle(admin, defaultFee) RecoverTokens(admin) {
        require(address(amlToken_) != address(0), "AMLTOracle: amlToken_ must not be 0x0");

        _amlToken = amlToken_;
    }

    /**
     * @dev See {IAMLTOracle-donateAMLT}.
     */
    function donateAMLT(address account, uint256 amount) external override {
        _transferHere(msg.sender, amount);
        _donate(msg.sender, account, amount);
    }

    /**
     * @dev See {IAMLTOracle-depositAMLT}.
     */
    function depositAMLT(uint256 amount) external override {
        _transferHere(msg.sender, amount);
        _deposit(msg.sender, amount);
    }

    /**
     * @dev See {IAMLTOracle-withdrawAMLT}.
     */
    function withdrawAMLT(uint256 amount) external override {
        _withdraw(msg.sender, amount);

        try _amlToken.transfer(msg.sender, amount) {
            return;
        } catch {
            assert(false); // We should never reach this!
        }
    }

    /**
     * @dev See {IAMLTOracle-fetchAMLStatusForAMLT} and
     * {IBaseAMLOracle-fetchAMLStatus}.
     *
     * This is an auxiliary function provided for convenience, and for building
     * innovative workflows. fetchAMLStatus() is the primary way to fetch
     * AML statuses. This is a relatively heavy weight process.
     */
    function fetchAMLStatusForAMLT(uint256 fee, string calldata target) external override returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        _transferHere(msg.sender, fee); // Checks-Effects-Interactions!

        _deposit(msg.sender, fee);

        return _fetchAMLStatus(msg.sender, target, fee);
    }

    /**
     * @dev See {IAMLTOracle-getAMLToken}.
     */
    function getAMLToken() public view override returns (IERC20 amlToken) {
        return _amlToken;
    }

    /**
     * @dev This function provides the total amount of assets to
     * {BaseAMLOracle} and others interested in Oracle's total asset balance.
     *
     * This differs from the {BaseAMLOracle-_totalDeposits}: unlike
     * _totalDeposits, this value can be forcefully increased, hence it must be
     * higher or equal to _totalDeposits.
     *
     * @return balance Oracle's current total balance
     */
    function getTotalBalance() public view override(BaseAMLOracle, IBaseAMLOracle) returns (uint256 balance) {
        return _amlToken.balanceOf(address(this));
    }

    /**
     * @dev See {IBaseAMLOracle-getInterfaceHash}.
     */
    function getInterfaceHash() public pure override(BaseAMLOracle, IBaseAMLOracle) returns (bytes32 interfaceHash) {
        return ERC1820INTERFACEHASH;
    }

    /**
     * @dev Internal function for transferring tokens to this contract.
     *
     * For inbound traffic we use the {IERC20-approve}->{IERC20-transferFrom}
     * pattern.
     *
     * @param from The adress which gave us allowance by calling `approve()`
     * @param amount The amount to transfer
     */
    function _transferHere(address from, uint256 amount) internal {
        try _amlToken.transferFrom(from, address(this), amount) {
            return;
        } catch {
            revert("AMLTOracle: token transferFrom() failed");
        }
    }

    /**
     * @dev Overriden function for telling RecoverTokens how many of _amlToken
     * we can actually recover. See {RecoverTokens-_tokensToBeRecovered}.
     */
    function _tokensToBeRecovered(IERC20 token) internal view override returns (uint256 amountToRecover) {
        if (address(token) == address(_amlToken)) {
            uint256 totalBalance = getTotalBalance();
            uint256 totalDeposits = getTotalDeposits();

            assert(totalBalance >= totalDeposits);

            return totalBalance.sub(totalDeposits);
        } else {
            return token.balanceOf(address(this));
        }
    }
}
