## `ETHOracle`



This AML Oracle works with Ether, and inherits {BaseAMLOracle}.


### `constructor(address admin, uint256 defaultFee)` (public)



Empty constructor, only invoking the {BaseAMLOracle-constructor}.

### `receive()` (external)



Receiving and depositing Ether.
On successful execution, {Deposited} EVM event is emitted.

### `donateETH(address account)` (external)



See {IETHOracle-donateETH}.

### `depositETH()` (external)



See {IETHOracle-depositETH}.

### `withdrawETH(uint256 amount)` (external)



See {IETHOracle-withdrawETH}.

### `fetchAMLStatusForETH(string target) → bytes32 amlID, uint8 cScore, uint120 flags` (external)



See {IETHOracle-fetchAMLStatusForETH} and
{IBaseAMLOracle-fetchAMLStatus}.

### `getTotalBalance() → uint256 balance` (public)



This function provides the total amount of assets to
{BaseAMLOracle} and others interested in Oracle's total asset balance.
This differs from the {BaseAMLOracle-_totalDeposits}: unlike
_totalDeposits, this value can be forcefully increased, hence it must be
higher or equal to _totalDeposits.


### `getInterfaceHash() → bytes32 interfaceHash` (public)



See {IBaseAMLOracle-getInterfaceHash}.


