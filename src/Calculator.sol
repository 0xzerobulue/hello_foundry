// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library MathLab {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function mul(uint256 a, uint256 b) public pure returns (uint256) {
        return a * b;
    }
}

contract Calculator {
    constructor() {}

    function testAdd(uint256 a, uint256 b) public pure returns (uint256) {
        return MathLab.add(a, b);
    }

    using MathLab for uint256;

    function testMax(uint256 a, uint256 b) public pure returns (uint256) {
        return a.max(b);
    }

    function testAdd2(uint256 a, uint256 b) public pure returns (uint256) {
        return a.add(b);
    }
}
