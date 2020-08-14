// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import 'openzeppelin-solidity/contracts/utils/Address.sol';
import "./AMLOracle.sol";

contract ETHOracle is AMLOracle {
    using Address for address payable;

    constructor(address admin) AMLOracle(admin) {

    }

    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    function donateETH(address client) external payable {
        _donate(msg.sender, client, msg.value);
    }

    function depositETH() external payable {
        _deposit(msg.sender, msg.value);
    }

    function withdrawETH(uint256 amount) external {
        _withdraw(msg.sender, amount);
        msg.sender.sendValue(amount);
    }

    function fetchAMLStatusForETH(string calldata target) external payable returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        _deposit(msg.sender, msg.value);
        return _fetchAMLStatus(msg.sender, target);
    }
}
