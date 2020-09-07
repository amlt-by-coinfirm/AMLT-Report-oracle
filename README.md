# Coinfirm AML Oracle smart contracts

**Coinfirm provides smart contracts on Ethereum a way to query AML Status of any
address on any of the blockchain networks supported by Coinfirm.**

## Quick start
`docker build .`

## Design overview
Coinfirm extends their AML service coverage to various on-chain applications on
Ethereum, like Distributed Exchanges (“DEX”).

To facilitate this, smart contracts are needed to provide such a service to ​ Client Smart Contracts
(like a DEX) on-chain.

Because of Ethereum’s technical limitations, ​ AML Status ​ query must be asynchronous, meaning
that the Client Smart Contract must query and fetch the status for any given address (on any
blockchain supported by Coinfirm) separately.

The design focuses on security and gas usage (so long term usage would be as cheap as
possible).

In the future there can be various Oracle smart contracts deployed in various configurations and
code revisions running in parallel. Each Oracle may implement different AML Status formats,
workflow and method of payment.

This initial design specifies two independent Oracles, one taking fees in Ether, and another in
AMLT (Coinfirm’s own AML Token).

## Design
![Design diagram in SVG](/design.svg)

- There is one base contract named ​ AMLOracle​ , which is inherited by user-facing ​ AMLTOracle
(for AMLT payments) and ​ ETHOracle​ (for Ether payments). Different smart contracts inheriting
the ​ AMLOracle​ can be introduced later, if needed.

- The contracts will inherit ​ AccessControl​ (for role based ownership/access control), and
Recoverable​ (for recovering foreign tokens) smart contracts. It will also rely on ​ EIP-1820
when querying the client smart contract’s willingness to accept donations.

- This design also allows non-custodial ownership of funds, and an inexpensive way to pay fees
to Coinfirm.

## Versions
The project should be compiled using the following software configuration:
 - Truffle v5.1.43 (core: 5.1.43)
 - Solidity - 0.7.0 (solc-js)
 - Node v10.22.0
 - Web3.js v1.2.1

Also a Dockerfile is provided as a template for a development environment.

We also use this particular [`solidity-docgen`](https://github.com/villesundell/solidity-docgen), `ethlint` and `ganache`.

## Audits
The code is not audited yet, but must be audited before its use in production.

The audit should cover only [`contracts/`](contracts/) without its subdirectories.

## Design choices

**The code is not upgradable​**: client smart contracts must be able to trust that the
Oracle stays unchanged, and does not break their contract. A new oracle (or an auxiliary
contract) shall be deployed if improvements are needed. For more information behind
this reasoning, please read my blogpost ​[here​](https://www.linkedin.com/pulse/when-code-must-law-smart-contracts-suits-ville-sundell) . An upgradable contract would not reduce
audit needs, since one single bug can still result in substantial financial loss.

**`get over `push`**​: due to Ethereum’s design, the Oracle must be asynchronous.
However, the Oracle could follow two design patterns:
 - **`get`**: fetch the address from the oracle. This was chosen because gas cost
would be always constant (and minimal) for Coinfirm.
 - **`push`**: oracle calls a callback function on the client contract. Downside is, that the
callback gas usage cannot be predicted (since that would be implementation
specific), and Coinfirm would need to take into account huge gas usage, and
expenses. Also this would make the client contract design harder, since the extra
gas cost when invoked the callback from the oracle should be taken into account.

**AML status is deleted for each address after ​`get()`​**:
 - This way a rogue actor cannot get an up-to-date AML database from the
blockchain (where ultimately all the information is publicly available), and
 - we get the gas refund (for deleting information on-chain).
Fee is paid only when ​ get()​ is called​ . This is important for two reasons:
 - This is vital for non-custodialship: the Oracle owner can’t confiscate client smart
contract’s tokens by specifying ridiculous fees.
 - One requirement was that fees might be different for different client smart
contracts, paying this kind of fee on ​ ask()​ would make the Oracle contract more
complicated.
 - In addition to ​ ask()->put()->get()​ pattern ​ put()->get()​ pattern is also
supported. Therefore it makes sense to pay the fee on ​ get()​ , as the last link of
the chain.

**Oracle deals with structured AML Statuses, instead of raw byte arrays​**: instead of
raw byte arrays, the Oracle uses hardcoded structures (technically, ​ tuples ​ ) for AML
Statuses. Although byte arrays would be easier to relay to the client smart contract, this
approach provides client smart contracts a convenient, reliable and fixed way to receive
AML Statuses, without requiring a custom-made deserialization code. If the format is
changed in the future, a new Oracle must be deployed.

**Gas Station Network not supported​**: since we are not serving the end customer
directly, it would be impractical to support the GSN: that’s Client Smart Contract’s job, if
they so desire.

**We name each return type**: we need to return a struct-alike for metadata and the AML status, and those should be named variables just for clarity. So for consistency and clarity, we name all the return variables we use. Also fits well to the new NatSpec addition of multiple return variables. We still use "return" to follow OpenZeppelin convention at the same time.

**We follow OpenZeppelin's encapsulation pattern**: [described here](https://ethereum.stackexchange.com/questions/67137/why-creating-a-private-variable-and-a-getter-instead-of-just-creating-a-public-v).

**Optimized gas usage**: we have optimized the most used workflow `ask`->`set`->`fetch` for low gas usage.

**BaseAMLOracle is not a library**: we believe it would make versioning more difficult, and the gas savings marginal, since in most cases of future development, a new BaseAMLOracle would be deployed anyway, making shared code footprint minimal. Each oracle is designed to be monolith and independent.

**AML status is not encrypted on-chain**: the statuses are meant to be read and used by smart contracts autonomously, so encryption cannot be used.

**NatSpec style combines traditional and OpenZeppelin approach**: this way we get best of both worlds, semantic documentation, and consistency with OpenZeppelin codebase. We use `@notice` once unconventionally: we believe that it emphasizes the importance. We also combine OpenZeppelin's commenting style for non-public variables ("//") with NatSpec's convention of ("/// @").

**No formal verification**: formal verification would be useless with projects of one author, since someone else should do the specification.

**Solidity version**: we use the *earliest safe Solidity from the series*, instead of the absolute newest one. This is to avoid regressions with recently released versions. At the time of writing, the latest Solidity was `0.7.1`, and the earliest safe Solidity of the `0.7.x` series was `0.7.0`. The code was written for the new 0.7.x series since Solidity team's [official stance](https://github.com/ethereum/solidity/releases/tag/v0.7.0) is that they won't maintain earlier serieses, and "it is recommended to upgrade all code to be compatible with Solidity v.0.7.0". Per Solidity versioning [best practices](https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version), we "float" Solidity version only with the files which are:
 - going to be used by third parties, such as interfaces, and
 - for testing, and not for on-chain use.

**Assert strategy**: we follow two different strategies when placing `assert()`s:
 - important state changes which could go wrong at Solidity/EVM level (because Solidity is growing increasingly more and more complicated), and
 - checking for states that should be impossible.

**Require strategy**: we verify user provided input for undesired default values (such as `address(0)`), and provide a human readable error message for easier troubleshooting.

**We follow OpenZeppelin's coding style and conventions**: since we are heavily utilizing OpenZeppelin, it makes sense to follow their coding style and conventions for consistency.

**RecoverTokens and AccessControl not exposed to the client smart contracts**: interfaces provided to third parties do not expose RecoverTokens nor AccessControl for simplicity. Client smart contracts should not need these functions, since these are only for the Oracle Operator.

**ETHOracle and AMLTOracle inherit RecoverTokens**: the token recovery functionality can be thought of as a feature of the oracle itself. Hence it's not inherited by the BaseAMLOracle.

**We rely on Truffle's versioning**: instead of implementing our own versioning, we use Truffle's migrations to keep accounts of versions.

**Explicit naming​**: ​ functions like `depositETH()​`, `​depositAMLT()`​, etc.​ are explicit for clarity.

**External/internal design pattern**: we implement our own design pattern, where `external` entry points use `internal` getters and setters.  We do this for two reasons: semantically it marks a user-accessible entry point, and gives us marginal gas savings when handling complex data types. Setters and getters from OpenZeppelin's contract encapsulation pattern also supports our pattern. Getters for unique variables (getters without arguments) are implemented as `public`.

**Externals in AMLTOracle and ETHOracle are not overridable**: Oracles themselves are not designed to be inherited. Oracles should consist of two parts: BaseAMLOracle and the contract implementing payment method(s). If you want extended functionality, create a new contract which inherits BaseAMLOracle.

**Transaction ordering is taken into account (security)**: most of the function calls are designed to be used within the same transaction (such as `getAMLStatusMetadata()` and `fetchAMLStatus()`), so transaction ordering is not a security problem. Also, `fetchAMLStatus()` with the optional `maxFee` can be used if desired. See the documentation for more details.

## Terminology
We use the following terminology in the code and related documentation:
- **oracle**: the whole monolithic contract `clients` interact with. Inherits `IBaseAMLOracle`.
- **account**: any account on Ethereum, might be a contract or externally operated.
- **client / client smart contract / user**: The smart contract/`account` using the Oracle. Oracles are designed to be used by smart contracts, but can be used by any Ethereum account.
- **oracle operator**: the entity managing the oracle and related off-chain services.
- **admin**: an entity managing the Oracle smart contract(s), and working for the Oracle Operator.
- **AML status**: general term for referring to any piece(s) of AML status information.
- **AMLStatus**: refers to the `AMLStatus` structure defined in `BaseAMLOracle.sol`, containing all the pieces for an AML status.
- **AML status database**: the oracle keeps all a separate database of `AMLStatus` entries for each client.
