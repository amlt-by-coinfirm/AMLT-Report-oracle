// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.6.10; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import 'openzeppelin-solidity/contracts/access/AccessControl.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './Recoverable.sol';

contract AMLOracle is AccessControl, Recoverable {
    using SafeMath for uint256;

    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
