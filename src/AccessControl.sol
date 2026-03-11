// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    // BUG: Anyone can call this, not just owner
    function initOwner(address _owner) external {
        owner = _owner;
    }

    function withdrawAll() external {
        require(msg.sender == owner, "Not owner");
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success);
    }
}
