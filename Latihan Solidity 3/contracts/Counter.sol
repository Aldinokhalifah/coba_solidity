// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract Counter {
    uint256 public count;

    function increment() public {
        count++;
    }

    function decrement() public {
        require(count > 0, "Counter: underflow");
        count--;
    }

    function reset() public {
        count = 0;
    }
}