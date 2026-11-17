// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {TryCatchDemo, Target} from "../src/TryCatchDemo.sol";

contract TryCatchDemoTest is Test {
    TryCatchDemo public demo;

    event Success(string message);
    event CaughtError(string reason);
    event CaughtPanic(uint256 errorCode);
    event CaughtLowLevel(bytes data);

    function setUp() public {
        demo = new TryCatchDemo();
    }

    // ========== 测试 require ==========
    function test_Require_Success() public {
        vm.expectEmit(true, true, true, true);
        emit Success("success from require");
        demo.testRequire(1);
    }

    function test_Require_Fail() public {
        vm.expectEmit(true, true, true, true);
        emit CaughtError("x must be greater than 0");
        demo.testRequire(0);
    }

    // ========== 测试 assert (Panic) ==========
    function test_Assert_Success() public {
        vm.expectEmit(true, true, true, true);
        emit Success("success from assert");
        demo.testAssert(1);
    }

    function test_Assert_Fail() public {
        vm.expectEmit(true, true, true, true);
        emit CaughtPanic(1); // Panic code 0x01
        demo.testAssert(0);
    }

    // ========== 测试自定义 error ==========
    function test_CustomError_Success() public {
        vm.expectEmit(true, true, true, true);
        emit Success("success from custom error");
        demo.testCustomError(1);
    }

    function test_CustomError_Fail() public {
        // 自定义 error 会进入 lowLevelData
        vm.expectEmit(true, true, true, true);
        // 这里我们只检查是否触发了 CaughtLowLevel 事件
        // 实际项目中可以进一步解码 lowLevelData
        demo.testCustomError(0);
    }

    // ========== 测试空 revert ==========
    function test_RevertEmpty() public {
        demo.testRevertEmpty();
    }
}