// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Calculator} from "../src/Calculator.sol";

contract CalculatorTest is Test {
    Calculator calculator;

    address public alice = makeAddr("alice");

    function setUp() public {
        calculator = new Calculator();
        vm.deal(alice, 10 ether);
    }

    function testAdd() public {
        vm.prank(alice);
        assertEq(calculator.testAdd(1, 2), 3);
    }

    function testMax() public {
        vm.prank(alice);
        assertEq(calculator.testMax(1, 2), 2);
    }
}
