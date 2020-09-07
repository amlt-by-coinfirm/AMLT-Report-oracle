// SPDX-License-Identifier: UNLICENCED
// Placeholder for an Example Decentralized Exchange
pragma solidity ^0.7.0; // See README.md for our Solidity version strategy

import "openzeppelin-solidity/contracts/introspection/IERC1820Registry.sol";
import "../IETHOracle.sol";

// This is for reference purposes only: it's full of security considerations
// and should not be used in production.
contract ExampleBank {
    IETHOracle public oracle;

    IERC1820Registry constant ERC1820REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping (address => bool) public verified;
    mapping (address => uint256) public balances;

    constructor(IETHOracle oracle_) {
        oracle = oracle_;
        ERC1820REGISTRY.setInterfaceImplementer(address(this), oracle.getInterfaceHash(), address(this));
    }

    function toString(address addr) public pure returns (string memory str) {
        bytes memory hexadecimals = "0123456789ABCDEF";
        bytes memory source = abi.encodePacked(addr);
        bytes memory tmp = new bytes(40);

        for (uint256 i = 0; i < 20; i++) {
            tmp[i*2] = hexadecimals[uint8(source[i] >> 4)];
            tmp[1+i*2] = hexadecimals[uint8(source[i] & 0x0F)];
        }

        return string(tmp);
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

    function deposit() public payable {
        require(verified[msg.sender], "ExampleBank: must be verified to deposit");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public payable {
        require(verified[msg.sender], "ExampleBank: must be verified to deposit");
        require(balances[msg.sender] >= amount, "ExampleBank: must have a positive balance");

        balances[msg.sender] -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");

        require(success, "ExampleBank: ether transfer was not successful");

        if (balances[msg.sender] == 0) {
            // Terminating relationship
            verified[msg.sender] = false;
        }
    }
}
