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
 */
contract AMLTOracle is RecoverTokens, BaseAMLOracle {
    using SafeMath for uint256; // Applicable only for uint256

    /**
     * @dev AMLT token contract address resides here. It's not hardcoded
     * so the same code could be run on many different networks (mainly for
     * testing purposes).
     */
    IERC20 public AMLToken;

    /**
     * @dev This constructor only sets the {AMLToken}, other initialization
     * tasks are done in {BaseAMLOracle}'s constructor.
     */
    constructor(address admin, uint256 defaultFee, IERC20 _AMLToken) BaseAMLOracle(admin, defaultFee) {
        AMLToken = _AMLToken;
    }

    /**
     * @dev See {IAMLTOracle-donateAMLT}.
     */
    function donateAMLT(address account, uint256 amount) external {
        _donate(msg.sender, account, amount);
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

        try AMLToken.transfer(msg.sender, amount) {
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
    function fetchAMLStatusForAMLT(string calldata target) external returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        AMLStatus memory status = _getAMLStatusCopy(msg.sender, target);
        uint256 fee = _getFee(status);

        _deposit(msg.sender, fee);

        _fetchAMLStatus(msg.sender, target);
        _transferHere(msg.sender, fee); // Checks-Effects-Interactions!

        return (status.amlID, status.cScore, status.flags);
    }

    function _tokensToBeRecovered(IERC20 token) internal view override returns (uint256 amount) {
        if (address(token) == address(AMLToken)) {
            return _getTotalBalance().sub(_getTotalDeposits());
        } else {
            return _getTokenBalance(token);
        }
    }

    function _transferHere(address from, uint256 amount) internal {
        try AMLToken.transferFrom(from, address(this), amount) {
            return;
        } catch {
            revert("AMLTOracle: Token transferFrom() failed");
        }
    }

    function _getTotalBalance() internal virtual override view returns (uint256 balance) {
        try AMLToken.balanceOf(address(this)) returns (uint256 totalBalance) {
            return totalBalance;
        } catch {
            revert("AMLTOracle: could not fetch total balance"); // Unique error message
        }
    }
}
