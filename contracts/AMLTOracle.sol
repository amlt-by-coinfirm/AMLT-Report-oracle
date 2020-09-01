// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // See README.md for our Solidity version strategy

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
 * Despite we work with trusted contract only ({_AMLToken}), we follow
 * Checks-Effects-Interactions pattern as a good practice, and to be
 * future-proof.
 */
contract AMLTOracle is RecoverTokens, BaseAMLOracle {
    using SafeMath for uint256; // Applicable only for uint256

    bytes32 public constant ERC1820INTERFACEHASH = keccak256(abi.encodePacked("AMLOracleAcceptDonationsInAMLT"));

    /**
     * @dev AMLT token contract address resides here. It's not hardcoded
     * so the same code could be run on many different networks (mainly for
     * testing purposes).
     */
    IERC20 private _AMLToken;

    /**
     * @dev This constructor only sets the {_AMLToken}, other initialization
     * tasks are done in {BaseAMLOracle}'s constructor.
     */
    constructor(address admin, uint256 defaultFee, IERC20 AMLToken_) BaseAMLOracle(admin, defaultFee) {
        _AMLToken = AMLToken_;
    }

    /**
     * @dev See {IAMLTOracle-donateAMLT}.
     */
    function donateAMLT(address account, uint256 amount) external {
        _donate(msg.sender, account, ERC1820INTERFACEHASH, amount);
        _transferHere(msg.sender, amount);
    }

    /**
     * @dev See {IAMLTOracle-depositAMLT}.
     */
    function depositAMLT(uint256 amount) external {
        _deposit(msg.sender, amount);
        _transferHere(msg.sender, amount);
    }

    /**
     * @dev See {IAMLTOracle-withdrawAMLT}.
     */
    function withdrawAMLT(uint256 amount) external {
        _withdraw(msg.sender, amount);

        try _AMLToken.transfer(msg.sender, amount) {
            return;
        } catch {
            revert("AMLTOracle: Token transfer() failed");
        }
    }

    /**
     * @dev See {IAMLTOracle-fetchAMLStatusForAMLT} and
     * {IBaseAMLOracle-fetchAMLStatus}.
     *
     * This is an auxiliary function provided for convenience, and for building
     * innovative workflows. fetchAMLStatus() is the primary way to fetch
     * AML statuses. This is relatively heavy weight process.
     */
    function fetchAMLStatusForAMLT(uint256 fee, string calldata target) external returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        _deposit(msg.sender, fee);

        (amlID, cScore, flags) = _fetchAMLStatus(msg.sender, target, fee);
        _transferHere(msg.sender, fee); // Checks-Effects-Interactions!

        return (amlID, cScore, flags);
    }

    function getAMLToken() public view returns (IERC20) {
        return _AMLToken;
    }

    function _tokensToBeRecovered(IERC20 token, uint256 amount) internal view override returns (uint256 amountToRecover) {
        if (address(token) == address(_AMLToken)) {
            // assert() here?
            uint256 recoverableAmount = _getTotalBalance().sub(_getTotalDeposits());
            require(recoverableAmount >= amount, "AMLTOracle: trying to recover more than allowed");
            return amount;
        } else {
            return amount;
        }
    }

    function _transferHere(address from, uint256 amount) internal {
        try _AMLToken.transferFrom(from, address(this), amount) {
            return;
        } catch {
            revert("AMLTOracle: Token transferFrom() failed");
        }
    }

    function _getTotalBalance() internal virtual override view returns (uint256 balance) {
        try _AMLToken.balanceOf(address(this)) returns (uint256 totalBalance) {
            return totalBalance;
        } catch {
            revert("AMLTOracle: could not fetch total balance");
        }
    }
}
