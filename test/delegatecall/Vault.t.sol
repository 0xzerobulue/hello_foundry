// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import {VaultProxy} from "../../src/delegatecall/VaultProxy.sol";
import {VaultV1} from "../../src/delegatecall/VaultV1.sol";
import {VaultV2} from "../..//src/delegatecall/VaultV2.sol";

contract VaultTest is Test {
    address admin = makeAddr("admin");
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    
    VaultV1 implementationV1; 
    VaultProxy proxy;
    VaultV1 vault;

    function setUp() public {
        implementationV1 = new VaultV1();
        proxy = new VaultProxy(address(implementationV1), admin, abi.encodeCall(VaultV1.initialize, owner));

        vault = VaultV1(payable(address(proxy)));
        vm.deal(alice, 10 ether);
    }

    function testInitialize() public view {
        assertEq(vault.owner(), owner);
        assertEq(vault.feeBps(), 50);
        assertEq(vault.version(), 1);
        assertEq(proxy.admin(), admin);
        assertEq(proxy.implementation(), address(implementationV1));
    
    }

    function testDeposit() public {
        vm.prank(alice);
        vault.deposit{value: 1 ether}();
        assertEq(vault.balances(alice), 1 ether);
        assertEq(address(proxy).balance, 1 ether);

        assertEq(implementationV1.balances(alice), 0);
        assertEq(address(implementationV1).balance, 0);

    }

    function testWithdraw() public {
        vm.startPrank(alice);
        vault.deposit{value: 1 ether}();
        vault.withdraw(1 ether);
        vm.stopPrank();

        assertEq(alice.balance, 9.995 ether);
        assertEq(vault.balances(alice), 0);
        assertEq(vault.accuredFees(), 0.005 ether);
        assertEq(address(proxy).balance, 0.005 ether);
    }

    function testDelegatecallContext() public {
        vm.prank(alice);
        ( address self, address sender, uint256 value ) = vault.context{value: 123}();
        assertEq(self, address(proxy));
        assertEq(sender, alice);
        assertEq(value, 123);
    }

    function testUpgradeToV2() public {
        vm.prank(alice);
        vault.deposit{value: 2 ether}();
        vm.prank(owner);
        vault.setFee(100);

        VaultV2 implementationV2 = new VaultV2();
        vm.prank(admin);
        proxy.upgradeTo(address(implementationV2));

        VaultV2 vaultV2 = VaultV2(payable(address(proxy)));

        assertEq(proxy.implementation(), address(implementationV2));
        assertEq(vaultV2.version(), 2);
        assertEq(vaultV2.owner(), owner);
        assertEq(vaultV2.feeBps(), 100);
        assertEq(vaultV2.balances(alice), 2 ether);
        assertEq(vaultV2.totalAssets(), 2 ether);

        (uint256 netAmount, uint256 fee) = vaultV2.previewWithdraw(1 ether);
        assertEq(netAmount, 0.99 ether);
        assertEq(fee, 0.01 ether);
        vm.prank(alice);
        vaultV2.withdraw(1 ether);
        assertEq(alice.balance, 8.99 ether);
        assertEq(vaultV2.balances(alice), 1 ether);
        assertEq(vaultV2.accuredFees(), 0.01 ether);
        assertEq(vaultV2.totalAssets(), 1.01 ether);


    }

    function testOnlyAdminCanUpgrade() public {
        VaultV2 implementationV2 = new VaultV2();
        vm.prank(alice);
        vm.expectRevert(bytes("Not admin"));
        proxy.upgradeTo(address(implementationV2));

        assertEq(proxy.implementation(), address(implementationV1));
    }
}



