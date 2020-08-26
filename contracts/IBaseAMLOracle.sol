// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.7.0; // See README.md for our Solidity version strategy

interface IBaseAMLOracle {
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
     * afterall, the client smart contract should act only on successful AML
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
     * @param client Client Smart Contract whose AML status database is
     * affected
     * @param target The address of the account whose AML status is affected
     */
    event AMLStatusSet(address indexed client, string target);

    /**
     * @dev Emitted when client smart contract fetches an AML status
     *
     * @param client Client Smart Contract whose AML status database is
     * affected
     * @param target The address of the account whose AML status is affected
     */
    event AMLStatusFetched(address indexed client, string target);

    /**
     * @dev Emitted when an account receives a donation.
     *
     * @param donor The address of the account donating the funds
     * @param account The address of the account receiving the funds
     * @param amount Amount of funds in the smallest denominator
     */
    event Donated(address indexed donor, address indexed account, uint256 amount);

    /**
     * @dev Emitted when an account deposit funds to itself.
     *
     * @param account The address of the account making the deposit
     * @param amount Amount of funds in the smallest denominator
     */
    event Deposited(address indexed account, uint256 amount);

    /**
     * @dev Emitted when an account withdraws its funds.
     *
     * @param account The address of the account making the withdrawal
     * @param amount Amount of funds in the smallest denominator
     */
    event Withdrawn(address indexed account, uint256 amount);

    /**
     * @dev Setting the default fee for AML status queries as the Oracle
     * Operator.
     *
     * The default fee could save some gas in situations where there is a
     * client smart contract with high volume of queries. In these cases the
     * fee per transaction can be 0 (omitting fees on storage), referring to
     * this particular value.
     *
     * This function is protected by our Role Based Access Control, and the
     * caller must have the role {SET_DEFAULT_FEE_ROLE}. By default the `admin`
     * has this role.
     *
     * On successful execution, {DefaultFeeSet} EVM event is emitted.
     *
     * @param defaultFee_ The new default fee
     */
    function setDefaultFee(uint256 defaultFee_) external;

    /**
     * @dev Setting the account where we pay the fees for each AML status
     * query as the Oracle Operator.
     *
     * For simplicity, we are paying fees only to one account. The change
     * affects future fees only.
     *
     * This function is protected by our Role Based Access Control, and the
     * caller must have the role {SET_FEE_ACCOUNT_ROLE}. By default the `admin`
     * has this role.
     *
     * On successful execution, {FeeAccountSet} EVM event is emitted.
     *
     * @param feeAccount_ New fee account
     */
    function setFeeAccount(address feeAccount_) external;

    /**
     * @dev Notifying a client via an EVM event with a free form ASCII string
     * as the Oracle Operator.
     *
     * Possible reasons include errors during AML status determination,
     * throttling because of suspected spam, or insufficient credit.
     *
     * This emitted event is not readable by smart contracts, and this is
     * intentional: afterall, the client smart contract should act only on
     * successful AML status requests. The errors are readable (and should be
     * monitored) by the client smart contract operator(s), if any.
     *
     * This function is protected by our Role Based Access Control, and the
     * caller must have the role {NOTIFY_ROLE}. By default the `admin`
     * has this role.
     *
     * On successful execution, {Notified} EVM event is emitted.
     *
     * @param client Address of the client who is the intended recipient of
     * this particular notification
     * @param message Free form ASCII string containing the message
     */
    function notify(address client, string calldata message) external;

    /**
     * @dev Setting/updating the AML status for a specific address for a
     * specific client as the Oracle Operator.
     *
     * The Oracle Operator can use this to set an arbitrary AML status for
     * an arbitrary address for an arbitrary client. The client might, or might
     * not, have requested the AML status. Client might, or might not, fetch
     * this AML status. If an AML status is already present on-chain, the
     * status will be updated.
     *
     * Timestamp is not checked for overflow, and this is intentionally done
     * for simplifying the code:
     * - the timestamp will overflow in ~10 nonillion (US) years (10,783,118,943,836,478,994,022,445,749,252), and
     * - the timestamp is not critical, the Oracle and Client can work well
     *   even if the timstamp is wrong.
     *
     * The cScore is enforced to contain values between 0 - 99 so the Client
     * can always trust that the range is fixed.
     *
     * This function is protected by our Role Based Access Control, and the
     * caller must have the role {SET_AML_STATUS_ROLE}. By default the `admin`
     * has this role.
     *
     * On successful execution, {AMLStatusSet} EVM event is emitted.
     *
     * @param client Address of the client whose AML status database will be
     * affected
     * @param target The address for which the {AMLStatus} entry will be
     * created or updated
     * @param amlID Reference provided by the Oracle Operator for off-chain
     * integration
     * @param cScore AML cScore provided by the Oracle Operator as a result
     * of their AML analysis (the range being from 0 to 99)
     * @param flags Additional flags provided (and defined) by the Oracle
     * Operator
     * @param fee Fee that the Client must pay during a fetch in order to
     * receive the {AMLStatus} data
     */
    function setAMLStatus(address client, string calldata target, bytes32 amlID, uint8 cScore, uint120 flags, uint256 fee) external;

    /**
     * @dev Delete the whole {AMLStatus} entry as the Oracle Operator
     *
     * The Oracle Operator can use this function to delete arbitrary AML
     * statuses from arbitrary Clients. This is only possible on statuses not
     * already fetched by Clients.
     *
     * Asserts are not needed here: deletion is not critical for the Oracle to
     * function properly.
     *
     * This function is protected by our Role Based Access Control, and the
     * caller must have the role {DELETE_AML_STATUS_ROLE}. By default the
     * `admin` has this role.
     *
     * On successful execution, {AMLStatusDeleted} EVM event is emitted.
     *
     * @param client Address of the client whose AML status database will be
     * affected
     * @param target The address of the account whose {AMLStatus} entry will be
     * deleted from the Oracle Database
     */
    function deleteAMLStatus(address client, string calldata target) external;

    /**
     * @dev Ask AML status as a Client.
     *
     * Client can use this function to ask an {AMLStatus} for an arbitrary address.
     * Asking is a part of the request process.
     *
     * No actual state change is done here to save gas: the only objective
     * is to notify the Oracle Operator via an EVM event to prepare AML status
     * for the Client.
     *
     * Anyone can call this function: its up to the Oracle Operator to arrange
     * spam prevention mechanisms. There are no conditions whatsoever on
     * calling this function.
     *
     * On successful execution, {AMLStatusAsked} EVM event is emitted.
     *
     * @param maxFee Maximum fee the Client is willing to pay, this is not
     * saved to the Oracle state, so the Client can later decide will they pay
     * the fee or not, since the fee is paid during fetch.
     * @param target An account the client would like to request AML status for
     */
    function askAMLStatus(uint256 maxFee, string calldata target) external;

    /**
     * @dev Fetching {AMLStatus} as a Client.
     *
     * The magic happens here: this is the way for a Client to fetch actual
     * AML data on an address.
     *
     * The {AMLStatus} entry in question is removed during fetch to get the
     * gas refund.
     *
     * The fee is paid during fetch.
     *
     * Anyone with a balance for the fee can call this function: no boarding
     * needed.
     *
     * On successful execution, {AMLStatusFetched} EVM event is emitted.
     *
     * @param target Address whose AML status will be fetched
     * @return amlID Reference provided by the Oracle Operator for off-chain
     * integration
     * @return cScore AML cScore provided by the Oracle Operator as a result
     * of their AML analysis (the range being from 0 to 99)
     * @return flags Additional flags provided (and defined) by the Oracle
     * Operator
     */
    function fetchAMLStatus(string calldata target) external returns (bytes32 amlID, uint8 cScore, uint120 flags);

    /**
     * @dev Get metadata regarding an {AMLStatus}.
     *
     * Anyone can call this to fetch metadata (`timestamp` and `fee`) regarding
     * an {AMLStatus} of any address of any Client: we don't consider this
     * information to be secret, and its possible that the Client is consisting
     * of multiple smart contracts.
     *
     * @param client Client in whose database the desired {AMLStatus} entry
     * resides
     * @param target Address of the desired {AMLStatus} entry
     * @return timestamp Timestamp when the {AMLStatus} entry was created, or
     * updated
     * @return fee The amount the Client must pay during fetch in order to
     * get the AML status data
     */
    function getAMLStatusMetadata(address client, string calldata target) external view returns (uint256 timestamp, uint256 fee);

    /**
     * @dev Getter for private variable _defaultFee.
     *
     * We follow OpenZeppelin's encapsulation pattern, so instead of `public`
     * and its native getter, we need to implement our own.
     *
     * This is public so it can be used as-is in derived contracts also.
     *
     * @return defaultFee Default fee for an AML status query
     */
    function getDefaultFee() external view returns (uint256 defaultFee);

    /**
     * @dev Getter for private variable _feeAccount.
     *
     * We follow OpenZeppelin's encapsulation pattern, so instead of `public`
     * and its native getter, we need to implement our own.
     *
     * This is public so it can be used as-is in derived contracts also.
     *
     * @return feeAccount Account where the fees are paid
     */
    function getFeeAccount() external view returns (address feeAccount);

    /**
     * @dev ERC-20 compatible getter for private _balances mapping containing
     * internal accounts of funds.
     *
     * We follow OpenZeppelin's encapsulation pattern, so instead of `public`
     * and its native getter, we need to implement our own.
     *
     * This is public so it can be used as-is in derived contracts also.
     *
     * @param account Which account's balance is requested
     * @return balance Balance for the account
     */
    function balanceOf(address account) external view returns (uint256 balance);
}
