Versions:
  * Nodejs: v12.18.3
  * NPM: 6.14.6
  * Truffle:
    Truffle v5.1.37 (core: 5.1.37)
    Solidity - 0.7.0 (solc-js)
    Node v12.18.3
    Web3.js v1.2.1

Design choices:
  * We name each return type: we need to return a struct-alike for metadata and the AML status, and those should be named variables just for clarity. So for consistency and clarity, we name all the return variables we use. Also fits well to the new NatSpec addition of multiple return variables.
  * https://ethereum.stackexchange.com/questions/67137/why-creating-a-private-variable-and-a-getter-instead-of-just-creating-a-public-v
  * virtual/override
  * Explain why AMLOracle is not a library
  * Return variables are named, but still we use "return;" (OpenZeppelin and new NatSpec)
  * No encryption due to technical limitations (client smart contracts should be able to decrypt it themselves)
  * Assert() strategy: at the end of the function try to get the same result, like in elementary school mathematics
  * NatSpec style combines traditional and OpenZeppelin approach
  * ETHOracle and AMLTOracle inherit RecoverTokens separately, it's their job
  * We combine OpenZeppelin's commenting style for non-public variables ("//") with NatSpec ("/// @")
  * Terms: client / client smart contract, AML status / AMLStatus
  * external->internal(calldata) pattern
  * Solidity version lock
  * No formal verification needed
