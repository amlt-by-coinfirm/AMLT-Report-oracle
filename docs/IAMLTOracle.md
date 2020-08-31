## `IAMLTOracle`






### `donateAMLT(address account, uint256 amount)` (external)



Donating AMLT to an account internally.
Before calling this function, the account must have called {AMLToken}'s
{IERC20-approve} approving this Oracle to access their tokens.
On successful execution, {Donated} EVM event is emitted.


### `depositAMLT(uint256 amount)` (external)



Deposit AMLT to an account internally.
This function transfers `amount` of tokens from the caller to caller's
internal balance for paying fees in the future.
Before calling this function, the account must have called {AMLToken}'s
{IERC20-approve} approving this Oracle to access their tokens.
On successful execution, {Deposited} EVM event is emitted.


### `withdrawAMLT(uint256 amount)` (external)



Withdraw AMLT tokens from caller's internal balance.
Will withdraw `amount` of AMLT tokens from caller's internal balance
to the caller themselves using {IERC20-transfer}.
On successful execution, {Withdrawn} EVM event is emitted.


### `fetchAMLStatusForAMLT(uint256 fee, string target) → bytes32 amlID, uint8 cScore, uint120 flags` (external)



Fetch an {AMLStatus} as a Client and pay the fee with the supplied
ether.
See {fetchAMLStatus} for details.
On successful execution, {AMLStatusFetched} EVM event is emitted.
The `fee` provided with the call can be thought as the maximum fee:
if the actual fee is less than the provided amount, excess amount is
deposited for later use (or withdrawal).


