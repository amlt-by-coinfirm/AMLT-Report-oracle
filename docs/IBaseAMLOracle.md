## `IBaseAMLOracle`






### `setDefaultFee(uint256 defaultFee_)` (external)



Setting the default fee for AML status queries as the Oracle
Operator.
The default fee could save some gas in situations where there is a
client smart contract with high volume of queries. In these cases the
fee per transaction can be 0 (omitting fees on storage), referring to
this particular value.
This function is protected by our Role Based Access Control, and the
caller must have the role {SET_DEFAULT_FEE_ROLE}. By default the `admin`
has this role.
On successful execution, {DefaultFeeSet} EVM event is emitted.


### `setFeeAccount(address feeAccount_)` (external)



Setting the account where we pay the fees for each AML status
query as the Oracle Operator.
For simplicity, we are paying fees only to one account. The change
affects future fees only.
This function is protected by our Role Based Access Control, and the
caller must have the role {SET_FEE_ACCOUNT_ROLE}. By default the `admin`
has this role.
On successful execution, {FeeAccountSet} EVM event is emitted.


### `notify(address client, string message)` (external)



Notifying a client via an EVM event with a free form ASCII string
as the Oracle Operator.
Possible reasons include errors during AML status determination,
throttling because of suspected spam, or insufficient credit.
This emitted event is not readable by smart contracts, and this is
intentional: afterall, the client smart contract should act only on
successful AML status requests. The errors are readable (and should be
monitored) by the client smart contract operator(s), if any.
This function is protected by our Role Based Access Control, and the
caller must have the role {NOTIFY_ROLE}. By default the `admin`
has this role.
On successful execution, {Notified} EVM event is emitted.


### `setAMLStatus(address client, string target, bytes32 amlID, uint8 cScore, uint120 flags, uint256 fee)` (external)



Setting/updating the AML status for a specific address for a
specific client as the Oracle Operator.
The Oracle Operator can use this to set an arbitrary AML status for
an arbitrary address for an arbitrary client. The client might, or might
not, have requested the AML status. Client might, or might not, fetch
this AML status. If an AML status is already present on-chain, the
status will be updated.
Timestamp is not checked for overflow, and this is intentionally done
for simplifying the code:
- the timestamp will overflow in ~10 nonillion (US) years (10,783,118,943,836,478,994,022,445,749,252), and
- the timestamp is not critical, the Oracle and Client can work well
even if the timstamp is wrong.
The cScore is enforced to contain values between 0 - 99 so the Client
can always trust that the range is fixed.
This function is protected by our Role Based Access Control, and the
caller must have the role {SET_AML_STATUS_ROLE}. By default the `admin`
has this role.
On successful execution, {AMLStatusSet} EVM event is emitted.


### `deleteAMLStatus(address client, string target)` (external)



Delete the whole {AMLStatus} entry as the Oracle Operator
The Oracle Operator can use this function to delete arbitrary AML
statuses from arbitrary Clients. This is only possible on statuses not
already fetched by Clients.
Asserts are not needed here: deletion is not critical for the Oracle to
function properly.
This function is protected by our Role Based Access Control, and the
caller must have the role {DELETE_AML_STATUS_ROLE}. By default the
`admin` has this role.
On successful execution, {AMLStatusDeleted} EVM event is emitted.


### `askAMLStatus(uint256 maxFee, string target)` (external)



Ask AML status as a Client.
Client can use this function to ask an {AMLStatus} for an arbitrary address.
Asking is a part of the request process.
No actual state change is done here to save gas: the only objective
is to notify the Oracle Operator via an EVM event to prepare AML status
for the Client.
Anyone can call this function: its up to the Oracle Operator to arrange
spam prevention mechanisms. There are no conditions whatsoever on
calling this function.
On successful execution, {AMLStatusAsked} EVM event is emitted.


### `fetchAMLStatus(uint256 maxFee, string target) → bytes32 amlID, uint8 cScore, uint120 flags` (external)



Fetching {AMLStatus} as a Client.
The magic happens here: this is the way for a Client to fetch actual
AML data on an address.
The {AMLStatus} entry in question is removed during fetch to get the
gas refund.
The fee is paid during fetch.
Anyone with a balance for the fee can call this function: no boarding
needed.
On successful execution, {AMLStatusFetched} EVM event is emitted.


### `fetchAMLStatus(string target) → bytes32 amlID, uint8 cScore, uint120 flags` (external)



Like {fetchAMLStatus} above, but with unlimited fees.

### `getAMLStatusMetadata(address client, string target) → uint256 timestamp, uint256 fee` (external)



Get metadata regarding an {AMLStatus}.
Anyone can call this to fetch metadata (`timestamp` and `fee`) regarding
an {AMLStatus} of any address of any Client: we don't consider this
information to be secret, and its possible that the Client is consisting
of multiple smart contracts.


### `getAMLStatusMetadata(string target) → uint256 timestamp, uint256 fee` (external)

Like {getAMLStatusMetadata} above, but presuming `client` to be the
caller.



### `getAMLStatusTimestamp(address client, string target) → uint256 timestamp` (external)



Client can query the timestamp only, if so desired.


### `getAMLStatusFee(address client, string target) → uint256 fee` (external)

{getAMLStatusMetadata} is the preferred way to access the fee
(and timestamp)! If you are using this function, please read this part
of the documentation carefully!


This function is provided only for client smart contract's
convenience, as a way to build alternative processes, if desired so.
If you are using this function, please keep in mind that the fee can be
0 in two occassions:
- there is no such {AMLStatus} entry, or
- default fee is used instead of per query fee.
{getAMLStatusMetadata} is the preferred way to access both, fee and
status, taking care of the edge cases described above.


### `getDefaultFee() → uint256 defaultFee` (external)



Getter for private variable _defaultFee.
We follow OpenZeppelin's encapsulation pattern, so instead of `public`
and its native getter, we need to implement our own.
This is public so it can be used as-is in derived contracts also.


### `getFeeAccount() → address feeAccount` (external)



Getter for private variable _feeAccount.
We follow OpenZeppelin's encapsulation pattern, so instead of `public`
and its native getter, we need to implement our own.
This is public so it can be used as-is in derived contracts also.


### `balanceOf(address account) → uint256 balance` (external)



ERC-20 compatible getter for private _balances mapping containing
internal accounts of funds.
We follow OpenZeppelin's encapsulation pattern, so instead of `public`
and its native getter, we need to implement our own.
This is public so it can be used as-is in derived contracts also.



### `DefaultFeeSet(uint256 oldDefaultFee, uint256 newDefaultFee)`



Emitted when default fee is set/changed.
Although it might make sense first to specify also the setter (because
of our Role Based Access Control there might be multiple), but in the
end that's not relevant information during normal operation. If some day
forensics is needed, the event is linked to the transaction which can be
used to determine the setter.
Zero fees are intentionally supported as the default fee.
(Fee per query can't be 0, though.)


### `FeeAccountSet(address oldFeeAccount, address newFeeAccount)`



Emitted when the account where to fee will be paid, is changed.
Although it might make sense first to specify also the setter (because
of our Role Based Access Control there might be multiple), but in the
end that's not relevant information during normal operation. If some day
forensics is needed, the event is linked to the transaction which can be
used to determine the setter.


### `Notified(address client, string message)`



Emitted when the Oracle Operator wants to communicate with the
client smart contract.
Possible reasons include errors during AML status determination,
throttling because of suspected spam, or insufficient credit.
Events are not readable by smart contracts, and this is intentional:
afterall, the client smart contract should act only on successful AML
Status requests. The errors are readable (and should be monitored) by
the client smart contract operator(s), if any.


### `AMLStatusDeleted(address client, string target)`



Emitted when an {AMLStatus} entry is deleted.
There are two ways for the Oracle Operator to nullify an {AMLStatus}:
either calling `setAMLStatus()` with null attributes, or deleting the
whole {AMLStatus} entry by calling `deleteAMLStatus()` directly
(emitting this event). This action deletes the whole entry, including
the timestamp (which `setAMLStatus()` can't nullify).
There are also two occassions on which this action can take place:
- Oracle Operator invokes `deleteAMLStatus()` directly, as described
above, or
- Client Smart Contract fetches an AML status, and the status is
subsequently removed.


### `AMLStatusAsked(address client, uint256 maxFee, string target)`



Emitted when client smart contract ask an AML status for an
address to be placed on-chain by the Oracle Operator.


### `AMLStatusSet(address client, string target)`



Emitted when the Oracle Operator places an AML status on-chain.


### `AMLStatusFetched(address client, string target)`



Emitted when client smart contract fetches an AML status


### `Donated(address donor, address account, uint256 amount)`



Emitted when an account receives a donation.


### `Deposited(address account, uint256 amount)`



Emitted when an account deposit funds to itself.


### `Withdrawn(address account, uint256 amount)`



Emitted when an account withdraws its funds.


