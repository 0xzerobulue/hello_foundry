// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Target {
    error CustomError(uint256 value);

    // 触发 require 错误 (Error(string))
    function willRequire(uint256 x) external pure returns (string memory) {
        require(x > 0, "x must be greater than 0");
        return "success from require";
    }

    // 触发 assert 错误 (Panic)
    function willAssert(uint256 x) external pure returns (string memory) {
        assert(x != 0); // x == 0 时触发 Panic(0x01)
        return "success from assert";
    }

    // 触发自定义 error
    function willCustomError(uint256 x) external pure returns (string memory) {
        if (x == 0) {
            revert CustomError(x);
        }
        return "success from custom error";
    }

    // 触发无消息的 revert
    function willRevertEmpty() external pure {
        revert();
    }
}

contract TryCatchDemo {
    event Success(string message);
    event CaughtError(string reason);
    event CaughtPanic(uint256 errorCode);
    event CaughtLowLevel(bytes data);

    Target public target;

    constructor() {
        target = new Target();
    }

    // 测试 require 错误
    function testRequire(uint256 x) external {
        try target.willRequire(x) returns (string memory result) {
            emit Success(result);
        } catch Error(string memory reason) {
            emit CaughtError(reason);
        } catch Panic(uint256 errorCode) {
            emit CaughtPanic(errorCode);
        } catch (bytes memory lowLevelData) {
            emit CaughtLowLevel(lowLevelData);
        }
    }

    // 测试 assert (Panic) 错误
    function testAssert(uint256 x) external {
        try target.willAssert(x) returns (string memory result) {
            emit Success(result);
        } catch Error(string memory reason) {
            emit CaughtError(reason);
        } catch Panic(uint256 errorCode) {
            emit CaughtPanic(errorCode);
        } catch (bytes memory lowLevelData) {
            emit CaughtLowLevel(lowLevelData);
        }
    }

    // 测试自定义 error
    function testCustomError(uint256 x) external {
        try target.willCustomError(x) returns (string memory result) {
            emit Success(result);
        } catch Error(string memory reason) {
            emit CaughtError(reason);
        } catch Panic(uint256 errorCode) {
            emit CaughtPanic(errorCode);
        } catch (bytes memory lowLevelData) {
            emit CaughtLowLevel(lowLevelData);
        }
    }

    // 测试空 revert
    function testRevertEmpty() external {
        try target.willRevertEmpty() {
            emit Success("should not reach here");
        } catch Error(string memory reason) {
            emit CaughtError(reason);
        } catch Panic(uint256 errorCode) {
            emit CaughtPanic(errorCode);
        } catch (bytes memory lowLevelData) {
            emit CaughtLowLevel(lowLevelData);
        }
    }
}
