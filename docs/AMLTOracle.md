## `AMLTOracle`



This AML Oracle works with AMLT tokens, and is based on
{BaseAMLOracle}.
Despite we work with trusted contract only {AMLToken}, we follow
Checks-Effects-Interactions pattern as a good practice, and to be
future-proof.


### `constructor(address admin, uint256 defaultFee, contract IERC20 _AMLToken)` (public)



This constructor only sets the {AMLToken}, other initialization
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
AML statuses. This is relatively heavy weight process.

### `_tokensToBeRecovered(contract IERC20 token, uint256 amount) → uint256 amountToRecover` (internal)





### `_transferHere(address from, uint256 amount)` (internal)





### `_getTotalBalance() → uint256 balance` (internal)






