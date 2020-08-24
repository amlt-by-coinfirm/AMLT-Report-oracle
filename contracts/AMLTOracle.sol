// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./BaseAMLOracle.sol";
import './RecoverTokens.sol';

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
    constructor(address admin, IERC20 _AMLToken) BaseAMLOracle(admin) {
        AMLToken = _AMLToken;
    }

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
    function donateAMLT(address account, uint256 amount) external {
        _donate(msg.sender, account, amount);
        _transferHere(msg.sender, amount);
    }

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
    function depositAMLT(uint256 amount) external {
        _deposit(msg.sender, amount);
        _transferHere(msg.sender, amount);
    }

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
    function withdrawAMLT(uint256 amount) external {
        _withdraw(msg.sender, amount);

        try AMLToken.transfer(msg.sender, amount) {
            return;
        } catch {
            revert("AMLTOracle: Token transfer() failed");
        }
    }

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
        try AMLToken.balanceOf(address(this)) returns (uint256 balance) {
            return balance;
        } catch {
            revert("AMLTOracle: could not fetch total balance"); // Unique error message
        }
    }
}
