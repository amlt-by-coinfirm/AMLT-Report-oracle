# Coinfirm AML Oracle smart contracts

## Quick start
`docker build .`

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

**We name each return type**: we need to return a struct-alike for metadata and the AML status, and those should be named variables just for clarity. So for consistency and clarity, we name all the return variables we use. Also fits well to the new NatSpec addition of multiple return variables. We still use "return" to follow OpenZeppelin convention at the same time.

**We follow OpenZeppelin's encapsulation pattern**: [described here](https://ethereum.stackexchange.com/questions/67137/why-creating-a-private-variable-and-a-getter-instead-of-just-creating-a-public-v).

**Optimized gas usage**: we have optimized the most used workflow `ask`->`set`->`fetch` for low gas usage.

**BaseAMLOracle is not a library**: we believe it would make versioning more difficult, and the gas savings marginal, since in most cases of future development, a new BaseAMLOracle would be deployed anyway, making shared code footprint minimal. Each oracle is designed to be monolith and independent.

**AML status is not encrypted on-chain**: the statuses are meant to be read and used by smart contract autonomously, so encryption cannot be used.

**NatSpec style combines traditional and OpenZeppelin approach**: this way we get best of the both worlds, semantic documentation, and consistency with OpenZeppelin codebase. We use `@notice` once unconventionally: we believe that it emphasizes the importance. We also combine OpenZeppelin's commenting style for non-public variables ("//") with NatSpec's convention of ("/// @").

**No formal verification**: formal verification would be useless with projects of one author, since someone else should do the specification.

**Solidity version**: we use *earliest safe Solidity from the series*, instead of the absolute newest one. This is to avoid regressions with recently released versions. At the time of writing, the latest Solidity was `0.7.1`, and the earliest safe Solidity of the `0.7.x` series was `0.7.0`. The code was written for the new 0.7.x series since Solidity team's [official stance](https://github.com/ethereum/solidity/releases/tag/v0.7.0) is, that they won't maintain earlier serieses, and "it is recommended to upgrade all code to be compatible with Solidity v.0.7.0". Per Solidity versioning [best practices](https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version), we "float" Solidity version only with the files which are:
 - going to be used by third parties, such as interfaces, and
 - for testing, and not for on-chain use.

**Assert strategy**: we follow two different strategies when placing `assert()`s:
 - important state changes which could go wrong at EVM level, and
 - checking for states that should be impossible.

**Require strategy**: we verify user provided input for undesired default values (such as `address(0)`), and provide a human readable error message for easier troubleshooting.

**We follow OpenZeppelin's coding style and conventions**: since we are heavily utilizing OpenZeppelin, it makes sense to follow their coding style and conventions for consistency.

**RecoverTokens and AccessControl not exposed to the client smart contracts**: interfaces provided to third parties does not expose RecoverTokens nor AccessControl for simplicity. Client smart contracts should not need these functions, since these are only for the Oracle Operator.

**ETHOracle and AMLTOracle inherit RecoverTokens**: the token recovery functionality can be thought as a feature of the oracle itself. Hence it's not inherited by the BaseAMLOracle.

**We rely on Truffle's versioning**: instead of implementing our own versioning, we use Truffle's migrations to keep accounts of versions.

**External/internal design pattern**: +calldata

**DEFAULT_ADMIN_ROLE must be transferred manually**:

**Externals in AMLTOracle and ETHOracle are not overridable**:

**Transaction ordering is taken into account (security)**: most of the function calls are designed to be used within the same transaction (such as `getAMLStatusMetadata()` and `fetchAMLStatus()`), so transaction ordering is not a security problem. Also, `fetchAMLStatus()` with the optional `maxFee` can be used if desired. See the documentation for more details.

  * Terminology: client/user, clinet/account, owner/operator/admin, etc. client / client smart contract, AML status / AMLStatus
