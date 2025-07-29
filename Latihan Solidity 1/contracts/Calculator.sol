// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0;

import "./Icalculator.sol";

contract Calculator {
    function add(uint a, uint b) external pure returns(uint) {
        return a + b;
    }

    function subtract(uint a, uint b) external pure returns(uint) {
        return a - b;
    }

    function divide(uint a, uint b) external pure returns(uint) {
        require(b != 0, "Can't Divided By 0");

        return a / b;
    }
}