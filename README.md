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

## Design choices
**We name each return type**: we need to return a struct-alike for metadata and the AML status, and those should be named variables just for clarity. So for consistency and clarity, we name all the return variables we use. Also fits well to the new NatSpec addition of multiple return variables. We still use "return" to follow OpenZeppelin convention at the same time.

**We follow OpenZeppelin's encapsulation pattern**: [described here](https://ethereum.stackexchange.com/questions/67137/why-creating-a-private-variable-and-a-getter-instead-of-just-creating-a-public-v)

**BaseAMLOracle is not a library**: we believe it would make versioning more difficult, and the gas savings marginal, since in most cases of future development, a new BaseAMLOracle would be deployed anyway, making shared code footprint minimal. Each oracle is designed to be monolith and independent.

**AML status is not encrypted on-chain**: The statuses are meant to be read and used by smart contract autonomously, so encryption cannot be used.

**NatSpec style combines traditional and OpenZeppelin approach**: This way we get best of the both worlds, semantic documentation, and consistency with OpenZeppelin codebase.

**External functions in BaseAMLOracle are overridable**: In the future it might be useful that the Oracle can override external entrypoints.

**No formal verification**: formal verification would be useless with projects of one author, since someone else should do the specification.

**Solidity version**: We use *earliest safe Solidity from the series*, instead of the absolute newest one. This is to avoid regressions with recently released versions. At the time of writing, the latest Solidity was `0.7.1`, and the earliest safe Solidity of the `0.7.x` series was `0.7.0`. The code was written for the new 0.7.x series since Solidity team's [official stance](https://github.com/ethereum/solidity/releases/tag/v0.7.0) is, that they won't maintain earlier serieses, and "it is recommended to upgrade all code to be compatible with Solidity v.0.7.0". Per Solidity versioning [best practices](https://consensys.github.io/smart-contract-best-practices/recommendations/#lock-pragmas-to-specific-compiler-version), we "float" Solidity version only with the files which are:
 - going to be used by third parties, such as interfaces, and
 - for testing, and not for on-chain use.



  * Assert() strategy: at the end of the function try to get the same result, like in elementary school mathematics, also the other reason..
  * ETHOracle and AMLTOracle inherit RecoverTokens separately, it's their job
  * We combine OpenZeppelin's commenting style for non-public variables ("//") with NatSpec ("/// @")
  * Terms: client / client smart contract, AML status / AMLStatus
  * external->internal(calldata) pattern
  * Audits should cover contracts/*.sol only
  * Many require()s are for client's/user's convenience. Also undesired default values such as 0 are handled somewhat, helping troubleshooting
  * Terminology: client/user, clinet/account, owner/operator/admin, etc.
  * @notice is used unconventionally
  * No problems with transaction ordering: mainly intended to be used inside the same transaction
  * RecoverToken is not interface'd: not meant for end user, only admin use only. Same with RBAC
  * Truffle takes care of versioning
  * AMLTOracle not inheriting a general EIP-20 Oracle: no need, too messy
  * Gas usage in ask()->set()-fetch() flow is optimized
  * Timestamp not critical
