// SPDX-License-Identifier: UNLICENCED
// Placeholder for an Example Decentralized Exchange
pragma solidity ^0.7.0; // See README.md for our Solidity version strategy

import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
import "../contracts/IETHOracle.sol";

contract ExampleBank {
    IETHOracle public oracle;

    IERC1820Registry constant ERC1820REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping (address => bool) verified;

    constructor(IETHOracle oracle_) {
        oracle = oracle_;
        ERC1820REGISTRY.setInterfaceImplementer(address(this), oracle.getInterfaceHash(), address(this));
    }

    function toString(address) public pure returns (string memory) {
        // There are many possible ways to convert address to string
        // But because of license and copyright issues, it cannot be
        // included here for now.
        return "bogusaddress";
    }

    function verifyMe() public {
        require(!verified[msg.sender], "ExampleBank: you are already verified");

        try oracle.fetchAMLStatus(1, toString(msg.sender)) returns (bytes32, uint8 cScore, uint120) {
            if (cScore > 0) {
                verified[msg.sender] = true;
            } else {
                revert("ExampleBank: cScore not high enough");
            }
        } catch {
            oracle.askAMLStatus(1, toString(msg.sender));
        }
    }
}
