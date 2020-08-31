# Coinfirm AML Oracle smart contracts

## Versions
The following versions were used during development:

  * Nodejs: v12.18.3
  * NPM: 6.14.6
  * Truffle:
    Truffle v5.1.37 (core: 5.1.37)
    Solidity - 0.7.0 (solc-js)
    Node v12.18.3
    Web3.js v1.2.1

Also a Dockerfile is provided as a template for a development environment.

## Design choices
**We name each return type**: we need to return a struct-alike for metadata and the AML status, and those should be named variables just for clarity. So for consistency and clarity, we name all the return variables we use. Also fits well to the new NatSpec addition of multiple return variables. We still use "return" to follow OpenZeppelin convention at the same time.

**We follow OpenZeppelin's encapsulation pattern**: [described here](https://ethereum.stackexchange.com/questions/67137/why-creating-a-private-variable-and-a-getter-instead-of-just-creating-a-public-v)

**BaseAMLOracle is not a library**: we believe it would make versioning more difficult, and the gas savings marginal, since in most cases of future development, a new BaseAMLOracle would be deployed anyway, making shared code footprint minimal.

**AML status is not encrypted on-chain**: The statuses are meant to be read and used by smart contract autonomously, so encryption cannot be used.

  * virtual/override
  * Assert() strategy: at the end of the function try to get the same result, like in elementary school mathematics, also the other reason..
  * NatSpec style combines traditional and OpenZeppelin approach
  * ETHOracle and AMLTOracle inherit RecoverTokens separately, it's their job
  * We combine OpenZeppelin's commenting style for non-public variables ("//") with NatSpec ("/// @")
  * Terms: client / client smart contract, AML status / AMLStatus
  * external->internal(calldata) pattern
  * Solidity version lock
  * No formal verification needed
  * Audits should cover contracts/*.sol only
  * Many require()s are for client's/user's convenience. Also default values such as 0 are handled somewhat, helping troubleshooting
  * Terminology: client/user, clinet/account, owner/operator/admin, etc.
  * @notice is used unconventionally
  * string length (target) not checked because of high gas usage
  * Formal verification not (yet) supported: single developer project would not benefit much
