// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage public simpleStorage;

    address public alice = makeAddr("alice");

    event Received(address indexed sender, uint256 amount, string method);

    event FallbackCalled(
        address indexed sender,
        uint256 amount,
        bytes data,
        string method
    );

    event doesNotExistCalled(address indexed sender, bytes data, uint256 i);

    function setUp() public {
        simpleStorage = new SimpleStorage();
        vm.deal(alice, 10 ether);
    }

    function testReceiveWithPlainTransfer() public {
        vm.expectEmit(true, true, true, true);
        emit Received(alice, 1 ether, "receive");

        vm.prank(alice);
        (bool success, ) = address(simpleStorage).call{value: 1 ether}("");
        assertTrue(success);

        assertEq(address(simpleStorage).balance, 1 ether);
    }

    // function testReceiveWithTransfer() public {
    //     vm.expectEmit(true, true, true, true);
    //     emit Received(alice, 1 ether, "receive");

    //     vm.prank(alice);
    //     payable(address(simpleStorage)).transfer(1 ether);
    //     assertEq(address(simpleStorage).balance, 1 ether);
    // }

    function testFallbackWithData() public {
        bytes memory data = abi.encodeWithSignature("doesNotExist()");
        vm.expectEmit(true, true, true, true);
        emit FallbackCalled(alice, 1 ether, data, "fallback");

        vm.prank(alice);
        (bool success, ) = address(simpleStorage).call{value: 1 ether}(data);
        assertTrue(success);

        assertEq(address(simpleStorage).balance, 1 ether);
    }

    // function testFallbackWithoutValue() public {
    //     bytes memory data = abi.encodeWithSignature(
    //         "doesNotExist(uint256)",
    //         123
    //     );
    //     vm.expectEmit(true, true, true, true);
    //     emit FallbackCalled(alice, 0, data, "fallback");

    //     vm.prank(alice);
    //     (bool success, ) = address(simpleStorage).call(data);
    //     assertTrue(success);
    // }

    function testDoesNotExist() public {
        bytes memory data = abi.encodeWithSignature(
            "doesNotExist(uint256)",
            123
        );

        vm.expectEmit(true, true, true, true);

        emit doesNotExistCalled(alice, data, 123);

        vm.prank(alice);
        (bool success, ) = address(simpleStorage).call(data);
        assertTrue(success);
    }

    function testDeposit() public {
        vm.prank(alice);
        simpleStorage.deposit{value: 1 ether}();

        assertEq(simpleStorage.getBalance(alice), 1 ether, "balance mismatch");
    }
}
