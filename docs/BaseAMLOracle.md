## `BaseAMLOracle`



This is the base contract for developing AML Oracles. AML Oracles
itself will consist of two parts:
- payment logic implemented by the AML Oracle itself, and
- rest of the AML Oracle logic, including AML Status handling and
non-custodial logic implemented in this contract.
This contract covers:
- non-custodial logic ({}),
- AML Status handling logic ({}), and
- fee handling.
We follow modern OpenZeppelin design pattern on contract encapsulation,
that's why we are using mainly `private` state variables with `internal`
setters and getters.
We also implement our own design pattern where client smart contract
accessible entry points are marked `external` for two reasons: semantically
it marks a user-accessible entry point, and gives us marginal gas savings
when handling complex data types. Setters and getters from OpenZeppelin's
contract encapsulation pattern also supports our pattern.
We also implement a granular role-based access control by inheriting
{AccessControl}. Because we combine role-based access control with function
based access control, we use function names as our role names. Role check is
done in `external` functions, where applicable.
Although our access control model is consistently function based, there is
one exception: FORCE_WITHDRAW_ROLE which can be used to skip the `assert()`
upon withdrawal if there is ever such need.
At first the _Oracle Operator_ is the _Admin_, but later the Operator can
assign various other actors to various roles, including the Admin.


### `constructor(address admin, uint256 defaultFee_)` (internal)



Constructor sets up the Role Based Access Control, and sets the
initial _feeAccount to `admin`.


### `setDefaultFee(uint256 defaultFee_)` (external)



See {IBaseAMLOracle-setDefaultFee}.

### `setFeeAccount(address feeAccount_)` (external)



See {IBaseAMLOracle-setFeeAccount}.

### `notify(address client, string message)` (external)



See {IBaseAMLOracle-notify}.

### `setAMLStatus(address client, string target, bytes32 amlID, uint8 cScore, uint120 flags, uint256 fee)` (external)



See {IBaseAMLOracle-setAMLStatus}.

### `deleteAMLStatus(address client, string target)` (external)



See {IBaseAMLOracle-deleteAMLStatus}.

### `askAMLStatus(uint256 maxFee, string target)` (external)



See {IBaseAMLOracle-askAMLStatus}.

### `fetchAMLStatus(string target) → bytes32 amlID, uint8 cScore, uint120 flags` (external)



See {IBaseAMLOracle-fetchAMLStatus}.

### `fetchAMLStatus(uint256 maxFee, string target) → bytes32 amlID, uint8 cScore, uint120 flags` (external)



See {IBaseAMLOracle-fetchAMLStatus}.

### `getAMLStatusMetadata(string target) → uint256 timestamp, uint256 fee` (external)



See {IBaseAMLOracle-getAMLStatusMetadata}.

### `getAMLStatusMetadata(address client, string target) → uint256 timestamp, uint256 fee` (external)



See {IBaseAMLOracle-getAMLStatusMetadata}.

### `getAMLStatusTimestamp(address client, string target) → uint256 timestamp` (external)



See {IBaseAMLOracle-getAMLStatusTimestamp}.

### `getAMLStatusFee(address client, string target) → uint256 fee` (external)

{getAMLStatusMetadata} is the preferred way to access the fee
(and timestamp)! If you are using this function, please read this part
of the documentation carefully!


See {IBaseAMLOracle-getAMLStatusFee}.

### `getDefaultFee() → uint256 defaultFee` (public)



See {IBaseAMLOracle-getDefaultFee}.

### `getFeeAccount() → address feeAccount` (public)



See {IBaseAMLOracle-getFeeAccount}.

### `balanceOf(address account) → uint256 balance` (public)



See {IBaseAMLOracle-balanceOf}.

### `_setAMLStatus(address client, string target, struct BaseAMLOracle.AMLStatus status)` (internal)





### `_deleteAMLStatus(address client, string target)` (internal)





### `_fetchAMLStatus(address client, string target, uint256 maxFee) → bytes32 amlID, uint8 cScore, uint120 flags` (internal)





### `_donate(address donor, address account, uint256 amount)` (internal)





### `_deposit(address account, uint256 amount)` (internal)





### `_withdraw(address account, uint256 amount)` (internal)





### `_getTotalDeposits() → uint256 totalDeposits` (internal)





### `_getAMLStatusCopy(address client, string target) → struct BaseAMLOracle.AMLStatus status` (internal)





### `_getFee(struct BaseAMLOracle.AMLStatus status) → uint256 fee` (internal)





### `_getTotalBalance() → uint256 balance` (internal)






