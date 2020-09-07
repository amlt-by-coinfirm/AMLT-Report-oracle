## `AMLTOracle`



This AML Oracle works with AMLT tokens, and is based on
{BaseAMLOracle}.
This is specific to AMLT token contract, and hence is not a generic
ERC-20 implementation. That's why we use the try/catch pattern only on
occasions where we know the token contract could revert().
AMLT token contract is a trusted contract, so following
Checks-Effects-Interactions pattern here would overly complicate things.


### `constructor(address admin, uint256 defaultFee, contract IERC20 amlToken_)` (public)



This constructor only sets the {_amlToken}, other initialization
tasks are done in {BaseAMLOracle}'s constructor.

### `donateAMLT(address account, uint256 amount)` (external)



See {IAMLTOracle-donateAMLT}.

### `depositAMLT(uint256 amount)` (external)



See {IAMLTOracle-depositAMLT}.

### `withdrawAMLT(uint256 amount)` (external)



See {IAMLTOracle-withdrawAMLT}.

### `fetchAMLStatusForAMLT(uint256 fee, string target) → bytes32 amlID, uint8 cScore, uint120 flags` (external)



See {IAMLTOracle-fetchAMLStatusForAMLT} and
{IBaseAMLOracle-fetchAMLStatus}.
This is an auxiliary function provided for convenience, and for building
innovative workflows. fetchAMLStatus() is the primary way to fetch
AML statuses. This is a relatively heavy weight process.

### `getAMLToken() → contract IERC20 amlToken` (public)



See {IAMLTOracle-getAMLToken}.

### `getTotalBalance() → uint256 balance` (public)



This function provides the total amount of assets to
{BaseAMLOracle} and others interested in Oracle's total asset balance.
This differs from the {BaseAMLOracle-_totalDeposits}: unlike
_totalDeposits, this value can be forcefully increased, hence it must be
higher or equal to _totalDeposits.


### `getInterfaceHash() → bytes32 interfaceHash` (public)



See {IBaseAMLOracle-getInterfaceHash}.

### `_transferHere(address from, uint256 amount)` (internal)



Internal function for transferring tokens to this contract.
For inbound traffic we use the {IERC20-approve}->{IERC20-transferFrom}
pattern.


### `_tokensToBeRecovered(contract IERC20 token) → uint256 amountToRecover` (internal)



Overriden function for telling RecoverTokens how many of _amlToken
we can actually recover. See {RecoverTokens-_tokensToBeRecovered}.


