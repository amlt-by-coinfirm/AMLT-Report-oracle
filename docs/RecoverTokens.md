## `RecoverTokens`



This contract provides a way for the contract operator to recover
tokens which were sent to this contract by accident by a 3rd party.
100% of the tokens owned by the contract will be recovered by default.
If the contract is intended to host tokens, the parent contract must
override `_tokensToBeRecovered()`.


### `constructor(address admin)` (public)



The constructor won't do much here: setting the admin to be the
recoverer (and role admin).


### `recoverTokens(contract IERC20 token)` (public)



Recover tokens accidentally sent to this contract.
This function is protected by our Role Based Access Control, and the
caller must have the role {RECOVER_TOKENS_ROLE}. By default the `admin`
has this role.
On successful execution, {RecoveredTokens} EVM event is emitted.


### `_tokensToBeRecovered(contract IERC20 token) → uint256 amountToRecover` (internal)



Function to determine how many tokens to recover.
This can be overridden by the parent contract, so tokens which should
reside in this contract, would not be recovered.



### `RecoveredTokens(contract IERC20 token, uint256 amount)`



Emitted when token recovery is done for the particular token.


