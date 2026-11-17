// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Study {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract TokenBank {
    IERC20Study public token;
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    bool private entered;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(IERC20Study _token) {
        require(address(_token).code.length > 0, "Invalid token");
        token = _token;
    }

    modifier nonReentrant() {
        require(!entered, "Reentrant call");
        entered = true;
        _;
        entered = false;
    }

    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Zero amount");

        uint256 beforeBalance = token.balanceOf(address(this));
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer in failed");
        uint256 afterBalance = token.balanceOf(address(this));
        require(afterBalance >= beforeBalance && afterBalance - beforeBalance == amount, "Incorrect transfer amount");

        balances[msg.sender] += amount;
        totalDeposits += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external  nonReentrant {
        require(amount > 0, "Zero amount");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        require(token.transfer(msg.sender, amount), "Transfer out failed");
        emit Withdrawn(msg.sender, amount);
    
    }
}