// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleStorage is Ownable {
    uint256 public favoriteNumber;

    mapping(address => uint256) public balances;

    constructor() Ownable(msg.sender) {}

    event Received(address indexed sender, uint256 amount, string method);

    event FallbackCalled(
        address indexed sender,
        uint256 amount,
        bytes data,
        string method
    );
    event doesNotExistCalled(address indexed sender, bytes data, uint256 i);

    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value, msg.data, "fallback");
    }
    // fallback() external  {}
    receive() external payable {
        emit Received(msg.sender, msg.value, "receive");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function doesNotExist(uint256 i) public {
        emit doesNotExistCalled(msg.sender, msg.data, i);
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        balances[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    function getBalance(address addr) public view returns (uint256) {
        return balances[addr];
    }
}
