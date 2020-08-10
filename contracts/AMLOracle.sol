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

    mapping (address => mapping (string => AMLStatus)) private _AMLStatuses;
    mapping (address => uint256) private _balances;

    address private _feeAccount;
    uint256 private _defaultFee;

    event AskAMLStatus(address indexed client, uint256 maxFee, string target);

    constructor(address owner) {
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
    }

    function setDefaultFee(uint256 defaultFee) external {
        _defaultFee = defaultFee;
    }

    function setFeeAccount(address feeAccount) external {
        _feeAccount = feeAccount;
    }

    function askAMLStatus(uint256 maxFee, string calldata target) external {
        emit AskAMLStatus(msg.sender, maxFee, target);
    }

    function setAMLStatus(address client, string calldata target, bytes32 amlID, uint8 cScore, uint120 flags, uint256 fee) external {
        _AMLStatuses[client][target] = AMLStatus(amlID, cScore, flags, uint128(block.timestamp), fee);
    }

    function deleteAMLStatus(address client, string calldata target) external {
        delete(_AMLStatuses[client][target]);
    }

    function fetchAMLStatus(string calldata target) external returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        return _fetchAMLStatus(msg.sender, target);
    }

    // Provide a way for AMLTOracle to access this data?
    function getMetadata(string calldata target) external view returns (uint256 timestamp, uint256 fee) {
        AMLStatus memory status = _AMLStatuses[msg.sender][target];
        return (status.timestamp, _getFee(status));
    }

    function getDefaultFee() public view returns (uint256 defaultFee) {
        return defaultFee;
    }

    function getFeeAccount() public view returns (address feeAccount) {
        return _feeAccount;
    }

    function balanceOf(address account) public view returns (uint256 balance) {
        return _balances[account];
    }

    function _fetchAMLStatus(address client, string memory target) internal returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        AMLStatus memory status = _AMLStatuses[client][target];
        require(status.timestamp > 0, "No such AML Status.");

        _balances[client] = _balances[client].sub(_getFee(status));
        _balances[feeAccount] = _balances[feeAccount].add(_getFee(status));
        delete(_AMLStatuses[client][target]);

        return (status.amlID, status.cScore, status.flags);
    }

    function _donate(address account, uint256 amount) internal {
        address recipient = ERC1820REGISTRY.getInterfaceImplementer(account, INTERFACEHASH);
        require(recipient != address(0), "Account does not accept donations.");
        _deposit(recipient, amount);
    }

    function _deposit(address account, uint256 amount) internal {
        _balances[account] = _balances[account].add(amount);
    }

    function _withdraw(address account, uint256 amount) internal {
        _balances[account] = _balances[account].sub(amount);
    }

    function _getFee(AMLStatus memory status) internal view returns (uint256 fee) {
        if (status.fee > 0) { // Braces for clarity
            return status.fee;
        } else {
            return defaultFee;
        }
    }
}
