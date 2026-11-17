// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract VaultV1 {
    address public owner;
    uint256 public feeBps;
    mapping(address => uint256) public balances;
    bool public paused;
    uint256 public accuredFees;
    uint256 private _entered;
    bool private _initialized;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 grossAmount, uint256 fee);
    event FeeUpdated(uint256 newFeeBps);
    event Paused(bool paused);
    event FeeCollected(address indexed recipient, uint256 amount);

    constructor() {
        _initialized = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    modifier nonReentrant() {
        require(_entered == 0, "Reentrant call");
        _entered = 1;
        _;
        _entered = 0;
    }

    function initialize(address _owner) external {
        require(!_initialized, "Already initialized");
        require(_owner != address(0), "Zero owner");
        _initialized = true;
        owner = _owner;
        feeBps = 50;
    }

    function deposit() public payable {
        require(!paused, "Paused");
        require(msg.value > 0, "Zero deposit");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);

    }

    receive() external payable {
        deposit();
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Zero withdrawal");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        uint256 fee = amount * feeBps / 10_000;
        balances[msg.sender] -= amount;
        accuredFees += fee;
        (bool ok, ) = payable(msg.sender).call{value: amount-fee}("");
        require(ok, "Withdraw failed");
        emit Withdrawn(msg.sender, amount, fee);
    }

    function setFee(uint256 newFeeBps) external onlyOwner {
        require(newFeeBps <= 1_000, "Fee too high");
        feeBps = newFeeBps;
        emit FeeUpdated(newFeeBps);
    }

    function collectFees(address payable recipient) external onlyOwner nonReentrant {
        require(recipient != address(0), "Zero recipient");
        uint256 amount = accuredFees;
        accuredFees = 0;
        (bool ok, ) = recipient.call{value: amount}("");
        require(ok, "Fee transfer failed");
        emit FeeCollected(recipient, amount);
    }

    function totalAssets() external view returns(uint256) {
        return address(this).balance;
    }

    function context() external payable returns (address self, address sender, uint256 value) {
        return (address(this), msg.sender, msg.value);
        
    }
    function version() external pure virtual returns(uint256) {
        return 1;
    }
}