// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StudyToken} from "../../src/token_bank/StudyToken.sol";

import {IERC20Study, TokenBank} from "../../src/token_bank/TokenBank.sol";


contract TokenBankTest is Test {

    uint256 constant UNIT = 1e6;

    StudyToken token;
    TokenBank bank;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");


    function setUp() public {
        token = new StudyToken(1000 * UNIT);
        bank = new TokenBank(IERC20Study(address(token)));
    }

    function testInitialSupply() public view {
        assertEq(token.decimals(), 6);
        assertEq(token.totalSupply(), 1000 * UNIT);
        assertEq(token.balanceOf(address(this)), 1000 * UNIT);
        assertEq(token.balanceOf(alice), 0);
    }
    
    function testTransfer() public {
        token.transfer(alice, 100 * UNIT);
        assertEq(token.balanceOf(alice), 100 * UNIT);
        assertEq(token.balanceOf(address(this)), 900 * UNIT);
        assertEq(token.totalSupply(), 1000 * UNIT);

        vm.expectRevert("Insufficient balance");
        token.transfer(alice, 1000 * UNIT);
        
    }

    function testApproveAndTransferFrom() public {
        token.transfer(alice, 100 * UNIT);
        vm.prank(alice);
        // allowance[alice][bob] = 30
        token.approve(bob, 30 * UNIT);
        assertEq(token.balanceOf(alice), 100 * UNIT);
        assertEq(token.allowance(alice, bob), 30 * UNIT);
        
        vm.prank(bob);
        token.transferFrom(alice, bob, 10 * UNIT);

        assertEq(token.balanceOf(alice), 90 * UNIT);
        assertEq(token.balanceOf(bob), 10 * UNIT);
        assertEq(token.allowance(alice, bob), 20 * UNIT);
        
    }

    function testDeposit() public {
        token.transfer(alice, 100 * UNIT);
        vm.startPrank(alice);
        token.approve(address(bank), 50 * UNIT);
        bank.deposit(50 * UNIT);
        vm.stopPrank();

        assertEq(token.balanceOf(alice), 50 * UNIT);
        assertEq(token.balanceOf(address(bank)), 50 * UNIT);

        assertEq(bank.balances(alice), 50 * UNIT);
        assertEq(bank.totalDeposits(), 50 * UNIT);
    }

    function testDepositAndWithdraw() public {
        token.transfer(alice, 100 * UNIT);

        vm.startPrank(alice);
        token.approve(address(bank), 50 * UNIT);
        bank.deposit(50 * UNIT);
        bank.withdraw(20 * UNIT);
        vm.stopPrank();

        assertEq(token.balanceOf(alice), 70 * UNIT);
        assertEq(token.balanceOf(address(bank)), 30 * UNIT);

        assertEq(bank.balances(alice), 30 * UNIT);
        assertEq(bank.totalDeposits(), 30 * UNIT);

    }

    function testCannotDepositWithoutApproval() public {
        token.transfer(alice, 10 * UNIT);

        vm.prank(alice);
        vm.expectRevert("Insufficient allowance");
        bank.deposit(10 * UNIT);

        assertEq(token.balanceOf(alice), 10 * UNIT);
        assertEq(token.balanceOf(address(bank)), 0);

        assertEq(bank.balances(alice), 0);
    }

    function testBobCannotWithdrawAliceDeposit() public {
        token.transfer(alice, 10 * UNIT);
        vm.startPrank(alice);
        token.approve(address(bank), 10 * UNIT);
        bank.deposit(10 * UNIT);
        vm.stopPrank();

        vm.prank(bob);
        vm.expectRevert("Insufficient balance");
        bank.withdraw(10 * UNIT);

        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(address(bank)), 10 * UNIT);
        assertEq(bank.balances(bob), 0);
        assertEq(bank.balances(alice), 10 * UNIT);
    }
}


