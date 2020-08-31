## `ETHOracle`



This AML Oracle works with Ether, and is based on {BaseAMLOracle}.


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

### `_getTotalBalance() → uint256 balance` (internal)






