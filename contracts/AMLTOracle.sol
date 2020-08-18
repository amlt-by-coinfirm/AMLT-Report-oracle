// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./AMLOracle.sol";

contract AMLTOracle is AMLOracle {
    using SafeMath for uint256; // Applicable only for uint256

    IERC20 public AMLToken;

    constructor(address admin, IERC20 _AMLToken) AMLOracle(admin) {
        AMLToken = _AMLToken;
    }

    function donateAMLT(address client, uint256 amount) external {
        _donate(msg.sender, client, amount);
        _transferHere(msg.sender, amount);
    }

    function depositAMLT(uint256 amount) external {
        _deposit(msg.sender, amount);
        _transferHere(msg.sender, amount);
    }

    function withdrawAMLT(uint256 amount) external {
        _withdraw(msg.sender, amount);

        try AMLToken.transfer(msg.sender, amount) {
            return;
        } catch {
            revert("AMLTOracle: Token transfer() failed");
        }
    }

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
