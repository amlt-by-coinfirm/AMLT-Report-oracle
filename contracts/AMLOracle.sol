// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
import 'openzeppelin-solidity/contracts/access/AccessControl.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './RecoverTokens.sol';

abstract contract AMLOracle is AccessControl, RecoverTokens {
    using SafeMath for uint256; // Applicable only for uint256

    struct AMLStatus {
        bytes32 amlID;
        uint8 cScore;
        uint120 flags;
        uint128 timestamp;
        uint256 fee;
    }

    bytes32 public constant SET_DEFAULT_FEE_ROLE = keccak256("setDefaultFee()");
    bytes32 public constant SET_FEE_ACCOUNT_ROLE = keccak256("setFeeAccount()");
    bytes32 public constant NOTIFY_ROLE = keccak256("notify()");
    bytes32 public constant SET_AML_STATUS_ROLE = keccak256("setAMLStatus()");
    bytes32 public constant SET_DELETE_AML_STATUS_ROLE = keccak256("deleteAMLStatus()");
    bytes32 public constant FORCE_WITHDRAW_ROLE = keccak256("FORCE_WITHDRAW");

    IERC1820Registry constant ERC1820REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 constant INTERFACEHASH = keccak256(abi.encodePacked("AMLOracleAcceptDonations"));

    mapping (address => mapping (string => AMLStatus)) private _AMLStatuses;
    mapping (address => uint256) private _balances;

    uint256 private _totalDeposits;
    address private _feeAccount;
    uint256 private _defaultFee;

    event DefaultFeeSet(uint256 oldDefaultFee, uint256 newDefaultFee);
    event FeeAccountSet(address oldFeeAccount, address newFeeAccount);
    event Notified(address indexed client, string message);
    event AMLStatusDeleted(address indexed client, string target);
    event AMLStatusAsked(address indexed client, uint256 maxFee, string target);
    event AMLStatusSet(address indexed client, string target);
    event AMLStatusFetched(address indexed client, string target);
    event Donated(address indexed donor, address indexed account, uint256 amount);
    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    constructor(address admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(SET_DEFAULT_FEE_ROLE, admin);
        _setupRole(SET_FEE_ACCOUNT_ROLE, admin);
        _setupRole(NOTIFY_ROLE, admin);
        _setupRole(SET_AML_STATUS_ROLE, admin);
        _setupRole(SET_DELETE_AML_STATUS_ROLE, admin);
        _setupRole(FORCE_WITHDRAW_ROLE, admin);

        _feeAccount = admin;
    }

    function setDefaultFee(uint256 defaultFee_) external {
        require(hasRole(SET_DEFAULT_FEE_ROLE, msg.sender), "AMLOracle: Caller is not allowed to set the default fee");

        emit DefaultFeeSet(_defaultFee, defaultFee_); // Omitting setter for consistency

        _defaultFee = defaultFee_;
        assert(_defaultFee == defaultFee_);
    }

    function setFeeAccount(address feeAccount_) external {
        require(hasRole(SET_FEE_ACCOUNT_ROLE, msg.sender), "AMLOracle: Caller is not allowed to set the fee account");

        emit FeeAccountSet(_feeAccount, feeAccount_); // Omitting setter for consistency

        _feeAccount = feeAccount_;
        assert(_feeAccount == feeAccount_);
    }

    function notify(address client, string calldata message) external {
        require(hasRole(NOTIFY_ROLE, msg.sender), "AMLOracle: Caller is not allowed to notify the clients");

        emit Notified(client, message);
    }

    function setAMLStatus(address client, string calldata target, bytes32 amlID, uint8 cScore, uint120 flags, uint256 fee) external {
        require(hasRole(SET_AML_STATUS_ROLE, msg.sender), "AMLOracle: Caller is not allowed to set AML Statuses");
        require(cScore < 100, "AMLOracle: The cScore must be between 0 and 99");
        AMLStatus memory status;

        status = AMLStatus(amlID, cScore, flags, uint128(block.timestamp), fee); // The timestamp is not critical, and will overflow in ~10 nonillion (US) years (10,783,118,943,836,478,994,022,445,749,252)
        _setAMLStatus(client, target, status);
    }

    function deleteAMLStatus(address client, string calldata target) external {
        require(hasRole(SET_DELETE_AML_STATUS_ROLE, msg.sender), "AMLOracle: Caller is not allowed to delete AML Statuses");

        delete(_AMLStatuses[client][target]);
        // No assert needed: even if the entry is not toally deleted, it's not a problem
        emit AMLStatusDeleted(client, target);
    }

    // "request" instead of "ask"?
    function askAMLStatus(uint256 maxFee, string calldata target) external {
        emit AMLStatusAsked(msg.sender, maxFee, target);
    }

    function fetchAMLStatus(string calldata target) external returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        return _fetchAMLStatus(msg.sender, target);
    }

    // Consider supporting issuing a "client"? It's not classified
    function getAMLStatusMetadata(address client, string calldata target) external view returns (uint256 timestamp, uint256 fee) {
        AMLStatus memory status = _getAMLStatusCopy(client, target);

        return (status.timestamp, _getFee(status));
    }

    function getDefaultFee() public view returns (uint256 defaultFee) {
        return _defaultFee;
    }

    function getFeeAccount() public view returns (address feeAccount) {
        return _feeAccount;
    }

    function balanceOf(address account) public view returns (uint256 balance) {
        return _balances[account];
    }

    function _setAMLStatus(address client, string calldata target, AMLStatus memory status) internal {
        _AMLStatuses[client][target] = status;

        emit AMLStatusSet(client, target);
    }

    function _fetchAMLStatus(address client, string calldata target) internal returns (bytes32 amlID, uint8 cScore, uint120 flags) {
        AMLStatus memory status = _getAMLStatusCopy(client, target);
        require(status.timestamp > 0, "No such AML Status.");

        _balances[client] = _balances[client].sub(_getFee(status));
        _balances[_feeAccount] = _balances[_feeAccount].add(_getFee(status));
        delete(_AMLStatuses[client][target]); //!

        emit AMLStatusFetched(client, target);
        return (status.amlID, status.cScore, status.flags);
    }

    function _donate(address donor, address account, uint256 amount) internal {
        address recipient = ERC1820REGISTRY.getInterfaceImplementer(account, INTERFACEHASH);
        require(recipient != address(0), "Account does not accept donations.");
        _deposit(recipient, amount);

        emit Donated(donor, recipient, amount);
    }

    function _deposit(address account, uint256 amount) internal {
        _balances[account] = _balances[account].add(amount);
        _totalDeposits = _totalDeposits.add(amount);

        assert(_getTotalBalance() >= _totalDeposits);
        emit Deposited(account, amount);
    }

    function _withdraw(address account, uint256 amount) internal {
        _balances[account] = _balances[account].sub(amount);
        _totalDeposits = _totalDeposits.sub(amount);

        if (!hasRole(FORCE_WITHDRAW_ROLE, account)) {
            assert(_getTotalBalance() >= _totalDeposits);
        }

        emit Withdrawn(account, amount);
    }

    function _getTotalDeposits() internal view returns (uint256 totalDeposits) {
        return _totalDeposits;
    }

    function _getAMLStatusCopy(address client, string calldata target) internal view returns (AMLStatus memory status) {
        return _AMLStatuses[client][target];
    }

    function _getFee(AMLStatus memory status) internal view returns (uint256 fee) {
        if (status.fee > 0) { // Braces for clarity
            return status.fee;
        } else {
            return _defaultFee;
        }
    }

    function _getTotalBalance() internal virtual view returns (uint256 balance);
}
