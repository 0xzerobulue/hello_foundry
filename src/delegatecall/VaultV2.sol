// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {VaultV1} from "./VaultV1.sol";

contract VaultV2 is VaultV1 {

    function previewWithdraw(uint256 amount) external view returns(uint256 netAmount, uint256 fee) {
        fee = amount * feeBps / 10_000;
        netAmount = amount - fee;
    }

    function version() external pure override returns(uint256) {
        return 2;
    }
}