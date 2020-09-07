## `IETHOracle`



This AML Oracle works with Ether, and inherits {BaseAMLOracle}.


### `donateETH(address account)` (external)



Donating Ether to an account internally.
Account receiving the donation must have AMLOracleAcceptDonationsInETH
interface set in the ERC-1820 Registry at
0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24. The interface indicates
willingness to accept donations from all AML ETHOracles, not just this
particular oracle.
On successful execution, {Donated} EVM event is emitted.


### `depositETH()` (external)



Depositing Ether internally for the sender.
On successful execution, {Deposited} EVM event is emitted.

### `withdrawETH(uint256 amount)` (external)



Withdraw Ether from sender's internal balance.
On successful execution, {Withdrawn} EVM event is emitted.


### `fetchAMLStatusForETH(string target) → bytes32 amlID, uint8 cScore, uint120 flags` (external)



Fetch an {AMLStatus} as a Client and pay the fee with the supplied
ether.
See {fetchAMLStatus} for details.
On successful execution, {AMLStatusFetched} EVM event is emitted.
The fee provided with the call can be thought as the maximum fee:
if the actual fee is less than the provided amount, excess amount is
deposited for later use (or withdrawal).


