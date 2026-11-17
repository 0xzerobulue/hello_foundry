import { ethers } from "ethers";

// ============ 配置 ============
const RPC_URL = "http://127.0.0.1:8545";          // 本地 anvil
const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

// ============ 连接 ============
const provider = new ethers.JsonRpcProvider(RPC_URL);

const abi = [
    "event Success(string message)",
    "event CaughtError(string reason)",
    "event CaughtPanic(uint256 errorCode)",
    "event CaughtLowLevel(bytes data)"
];

// 如果只是监听事件，不需要 privateKey
const contract = new ethers.Contract(CONTRACT_ADDRESS, abi, provider);



// ============ 监听事件 ============

// 1. 监听 Success 事件
contract.on("Success", (message, event) => {
    console.log("✅ Success 事件触发");
    console.log("   message :", message);
    console.log("   txHash  :", event.log.transactionHash);
    console.log("----------------------------------");
});

// 2. 监听 CaughtError 事件（require 失败）
contract.on("CaughtError", (reason, event) => {
    console.log("❌ CaughtError 事件触发");
    console.log("   reason  :", reason);
    console.log("   txHash  :", event.log.transactionHash);
    console.log("----------------------------------");
});

// 3. 监听 CaughtPanic 事件（assert 失败）
contract.on("CaughtPanic", (errorCode, event) => {
    console.log("💥 CaughtPanic 事件触发");
    console.log("   errorCode:", errorCode.toString());
    console.log("   txHash   :", event.log.transactionHash);
    console.log("----------------------------------");
});

// 4. 监听 CaughtLowLevel 事件（自定义 error / 空 revert）
contract.on("CaughtLowLevel", (data, event) => {
    console.log("⚠️  CaughtLowLevel 事件触发");
    console.log("   data    :", data);
    console.log("   txHash  :", event.log.transactionHash);
    console.log("----------------------------------");
});

console.log("开始监听事件...（请在另一个终端调用合约函数）");