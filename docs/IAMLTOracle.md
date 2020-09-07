## `IAMLTOracle`



This AML Oracle works with AMLT tokens, and is based on
{BaseAMLOracle}.
This is specific to AMLT token contract, and hence is not a generic
ERC-20 implementation.


### `donateAMLT(address account, uint256 amount)` (external)



Donating AMLT to an account internally.
Before calling this function, the account must have called {_amlToken}'s
{IERC20-approve} approving this Oracle to access their tokens.
Account receiving the donation must have AMLOracleAcceptDonationsInAMLT
interface set in the ERC-1820 Registry at
0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24. The interface indicates
willingness to accept donations from all AMLT Oracles, not just this
particular oracle.
On successful execution, {Donated} EVM event is emitted.


### `depositAMLT(uint256 amount)` (external)



Deposit AMLT to an account internally.
This function transfers the `amount` of tokens from the caller to
caller's internal balance for paying fees in the future.
Before calling this function, the account must have called {_amlToken}'s
{IERC20-approve} approving this Oracle to access their tokens.
On successful execution, {Deposited} EVM event is emitted.


### `withdrawAMLT(uint256 amount)` (external)



Withdraw AMLT tokens from caller's internal balance.
Will withdraw an `amount` of AMLT tokens from caller's internal balance
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

### `getAMLToken() → contract IERC20 token` (external)



This returns {_amlToken}.
Since we are following OpenZeppelin's encapsulation design pattern,
each private state variable should have a getter, if meant to be used
by third parties. This can be used to check if the token is set
correctly.



