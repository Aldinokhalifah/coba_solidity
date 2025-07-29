// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0;

import "./Icalculator.sol";

contract CalculatorCaller {
    function getAddition(address calcAddress, uint a, uint b) public pure returns (uint) {
        Icalculator calculator = Icalculator(calcAddress);
        return calculator.add(a, b);
    }

    function getSubtraction(address calcAddress, uint a, uint b) public pure returns (uint) {
        Icalculator calculator = Icalculator(calcAddress);
        return calculator.subtract(a, b);
    }

    function getDivided(address calcAddress, uint a, uint b) public pure returns (uint) {
        Icalculator calculator = Icalculator(calcAddress);
        return calculator.divide(a, b);
    }
}