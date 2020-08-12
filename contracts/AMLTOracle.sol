// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./AMLOracle.sol";

contract AMLTOracle is AMLOracle {
    using SafeMath for uint256; // Applicable only for uint256

    IERC20 public AMLToken;
    uint256 public totalBalance;

    constructor(address owner, IERC20 _AMLToken) AMLOracle(owner) {
        AMLToken = _AMLToken;
    }

    function donateAMLT(address client, uint256 amount) external {
        _donate(client, amount);
        _transferHere(msg.sender, amount);
    }

    function depositAMLT(uint256 amount) external {
        _deposit(msg.sender, amount);
        _transferHere(msg.sender, amount);
    }

    function withdrawAMLT(uint256 amount) external {
        totalBalance = totalBalance.sub(amount);
        _withdraw(msg.sender, amount);

        try AMLToken.transfer(msg.sender, amount) {
            return;
        } catch {
            revert("AMLTOracle: Token transfer() failed");
        }
    }

    function tokensToBeReturned(IERC20 token) public view override returns (uint256) {
        if (address(token) == address(AMLToken)) {
            return token.balanceOf(address(this)).sub(totalBalance);
        } else {
            return token.balanceOf(address(this));
        }
    }

    function _transferHere(address from, uint256 amount) internal {
        totalBalance = totalBalance.add(amount);

        try AMLToken.transferFrom(from, address(this), amount) {
            return;
        } catch {
            revert("AMLTOracle: Token transferFrom() failed");
        }
    }
}
