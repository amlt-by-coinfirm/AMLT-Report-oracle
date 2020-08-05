// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
import 'openzeppelin-solidity/contracts/access/AccessControl.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './Recoverable.sol';

contract AMLOracle is AccessControl, Recoverable {
    using SafeMath for uint256; // Applicable only for uint256

    IERC1820Registry constant ERC1820REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 constant INTERFACEHASH = keccak256(abi.encodePacked("AMLOracleAcceptDonations"));

    struct AMLStatus {
        bytes32 amlID;
        uint8 cScore;
        uint120 flags;
        uint128 timestamp;
        uint256 fee;
    }

    mapping (address => mapping (string => AMLStatus)) AMLStatuses;
    mapping (address => uint256) balances; // Cheaper getter (optinally can use EIP-20 compatible balanceOf()).

    address public feeAccount;

    uint256 public defaultFee; // Cheaper getter.

    event AskAMLStatus(string target);

    constructor(address owner) {
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
    }

    function balanceOf(address account) external view returns (uint256 balance) {
        return balances[account];
    }

    function setDefaultFee(uint256 _defaultFee) external {
        defaultFee = defaultFee.add(_defaultFee);
    }

    function setFeeAccount(address _feeAccount) external {
        feeAccount = _feeAccount;
    }

    function ask(string calldata target) external {
        emit AskAMLStatus(target);
    }

    function put(address client, string calldata target, bytes32 amlID, uint8 cScore, uint120 flags, uint256 fee) external {
        AMLStatuses[client][target] = AMLStatus(amlID, cScore, flags, uint128(block.timestamp), fee);
    }

    function remove(address client, string calldata target) external {
        delete(AMLStatuses[client][target]);
    }

    function get(string calldata target) external returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        AMLStatus memory status = AMLStatuses[msg.sender][target];
        require(status.timestamp > 0, "No such AML Status.");

        balances[msg.sender] = balances[msg.sender].sub(_getFee(status));
        balances[feeAccount] = balances[feeAccount].add(_getFee(status));
        delete(AMLStatuses[msg.sender][target]);

        return (status.amlID, status.cScore, status.flags);
    }

    function getMetadata(string calldata target) external view returns (uint256 timestamp, uint256 fee) {
        AMLStatus memory status = AMLStatuses[msg.sender][target];
        return (status.timestamp, _getFee(status));
    }

    function _donate(address account, uint256 amount) internal {
        address recipient = ERC1820REGISTRY.getInterfaceImplementer(account, INTERFACEHASH);
        require(recipient != address(0), "Account does not accept donations.");
        _deposit(recipient, amount);
    }

    function _deposit(address account, uint256 amount) internal {
        balances[account] = balances[account].add(amount);
    }

    function _withdraw(address account, uint256 amount) internal {
        balances[account] = balances[account].sub(amount);
    }

    function _getFee(AMLStatus memory status) internal view returns (uint256 fee) {
        if (status.fee > 0) { // Braces for clarity
            return status.fee;
        } else {
            return defaultFee;
        }
    }
}
