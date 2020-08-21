// SPDX-License-Identifier: UNLICENCED

// We lock the Solidity version, per:
// https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version
pragma solidity 0.7.0; // Avoiding regressions by using the oldest safe Solidity, instead of the latest

import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
import 'openzeppelin-solidity/contracts/access/AccessControl.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * @title BaseAMLOracle - the abstract base contract for developing AML Oracles
 * @author Ville Sundell <development@solarius.fi>
 * @dev This is the base contract for developing AML Oracles. AML Oracles
 * itself will consist of two parts:
 *  - payment logic implemented by the AML Oracle itself, and
 *  - rest of the AML Oracle logic, including AML Status handling and
 *    non-custodial logic implemented in this contract.
 *
 * This contract covers:
 *  - non-custodial logic ({}),
 *  - AML Status handling logic ({}), and
 *  - fee handling.
 *
 * We follow modern OpenZeppelin design pattern on contract encapsulation,
 * that's why we are using mainly `private` state variables with `internal`
 * setters and getters.
 *
 * We also implement our own design pattern where client smart contract
 * accessible entry points are marked `external` for two reasons: semantically
 * it marks a user-accessible entry point, and gives us marginal gas savings
 * when handling complex data types. Setters and getters from OpenZeppelin's
 * contract encapsulation pattern also supports our pattern.
 *
 * We also implement a granular role-based access control by inheriting
 * {AccessControl}. Because we combine role-based access control with function
 * based access control, we use function names as our role names. Role check is
 * done in `external` functions, where applicable.
 *
 * Although our access control model is consistently function based, there is
 * one exception: FORCE_WITHDRAW_ROLE which can be used to skip the `assert()`
 * upon withdrawal if there is ever such need.
 *
 * At first the _Oracle Operator_ is the _Admin_, but later the Operator can
 * assign various other actors to various roles, including the Admin.
 */
abstract contract BaseAMLOracle is AccessControl {
    using SafeMath for uint256; // Applicable only for uint256

    /// @dev The core structure containing all the information for an AML Status
    struct AMLStatus {
        bytes32 amlID;
        uint8 cScore;
        uint120 flags;
        uint128 timestamp;
        uint256 fee;
    }

    // Roles for our Role Based Access Control model which combines function based access control:
    bytes32 public constant SET_DEFAULT_FEE_ROLE = keccak256("setDefaultFee()");
    bytes32 public constant SET_FEE_ACCOUNT_ROLE = keccak256("setFeeAccount()");
    bytes32 public constant NOTIFY_ROLE = keccak256("notify()");
    bytes32 public constant SET_AML_STATUS_ROLE = keccak256("setAMLStatus()");
    bytes32 public constant SET_DELETE_AML_STATUS_ROLE = keccak256("deleteAMLStatus()");
    bytes32 public constant FORCE_WITHDRAW_ROLE = keccak256("FORCE_WITHDRAW");

    // Two hard-coded constants for our ERC1820 support:
    IERC1820Registry constant ERC1820REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 constant INTERFACEHASH = keccak256(abi.encodePacked("AMLOracleAcceptDonations"));

    /// @dev All the {AMLStatus} entries reside here
    mapping (address => mapping (string => AMLStatus)) private _AMLStatuses;
    /// @dev Balance tracking for non-custodial and fee handling logic is done here
    mapping (address => uint256) private _balances;

    /// @dev Primary purpose is to provide `assert()`s regarding our
    /// non-custodial logic a way to compare balances.
    uint256 private _totalDeposits;
    /// @dev This is the account where the fees are paid upon `_fetchAMLStatus()`
    address private _feeAccount;
    /// @dev We store default fee, so upon placing an {AMLStatus} on chain, we
    /// can save some gas by not setting the fee, if so desired.
    uint256 private _defaultFee;

    /**
     * @dev Emitted when default fee is set/changed.
     *
     * Although it might make sense first to specify also the setter (because
     * of our Role Based Access Control there might be multiple), but in the
     * end that's not relevant information during normal operation. If some day
     * forensics is needed, the event is linked to the transaction which can be
     * used to determine the setter.
     *
     * @param oldDefaultFee What was the default fee before this event was
     * emitted
     * @param newDefaultFee What is the default fee after this event  was
     * emitted, and onwards
     */
    event DefaultFeeSet(uint256 oldDefaultFee, uint256 newDefaultFee);

    /**
     * @dev Emitted when the account where to fee will be paid, is changed.
     *
     * Although it might make sense first to specify also the setter (because
     * of our Role Based Access Control there might be multiple), but in the
     * end that's not relevant information during normal operation. If some day
     * forensics is needed, the event is linked to the transaction which can be
     * used to determine the setter.
     *
     * @param oldFeeAccount The fee account before this event was emitted
     * @param newFeeAccount The fee account after this event was emitted, and
     * onwards.
     */
    event FeeAccountSet(address oldFeeAccount, address newFeeAccount);

    /**
     * @dev Emitted when the Oracle Operator wants to communicate with the
     * client smart contract.
     *
     * Possible reasons include errors during AML status determination,
     * throttling because of suspected spam, or insufficient credit.
     *
     * Events are not readable by smart contracts, and this is intentional:
     * afterall, the client smart contract should act only on succesfull AML
     * Status requests. The errors are readable (and should be monitored) by
     * the client smart contract operator(s), if any.
     *
     * @param client The client smart contract, which is the recipient of the
     * communication
     * @param message The actual message as an ASCII string
     */
    event Notified(address indexed client, string message);

    /**
     * @dev Emitted when an {AMLStatus} entry is deleted.
     *
     * There are two ways for the Oracle Operator to nullify an {AMLStatus}:
     * either calling `setAMLStatus()` with null attributes, or deleting the
     * whole {AMLStatus} entry by calling `deleteAMLStatus()` directly
     * (emitting this event). This action deletes the whole entry, including
     * the timestamp (which `setAMLStatus()` can't nullify).
     *
     * There are also two occassions on which this action can take place:
     * - Oracle Operator invokes `deleteAMLStatus()` directly, as described
         above, or
     * - Client Smart Contract fetches an AML status, and the status is
     *   subsequently removed.
     *
     * @param client Client smart contract whose AML status database is affected
     * @param target The target address whose {AMLStatus} was deleted
     */
    event AMLStatusDeleted(address indexed client, string target);

    /**
     * @dev Emitted when client smart contract ask an AML status for an
     * address to be placed on-chain by the Oracle Operator.
     *
     * @param client Client smart contract asking the AML status
     * @param maxFee How much the client smart contract is willing to pay for
     * the status
     * @param target The address whose AML status the Client is requesting
     */
    event AMLStatusAsked(address indexed client, uint256 maxFee, string target);

    /**
     * @dev Emitted when the Oracle Operator places an AML status on-chain.
     *
     * @param client
     * @param target
     */
    event AMLStatusSet(address indexed client, string target);

    /**
     * @dev Emitted when client smart contract fetches an AML status
     *
     * @param client
     * @param target
     */
    event AMLStatusFetched(address indexed client, string target);

    /**
     * @dev Emitted when an account receives a donation.
     *
     * @param donor
     * @param account
     * @param amount
     */
    event Donated(address indexed donor, address indexed account, uint256 amount);

    /**
     * @dev Emitted when an account deposit funds to itself.
     *
     * @param account
     * @param amount
     */
    event Deposited(address indexed account, uint256 amount);

    /**
     * @dev Emitted when an account withdraws its funds.
     *
     * @param account
     * @param amount 
     */
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
        delete(_AMLStatuses[client][target]); //!, Place this to own internal function with the event?

        emit AMLStatusFetched(client, target);
        emit AMLStatusDeleted(client, target);
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
