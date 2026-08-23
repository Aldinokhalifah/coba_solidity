// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract SimpleStorage {
    struct User {
        string name;
        uint256 age;
    }

    mapping(address => User) public users;

    function setUser(string memory name, uint256 age) public {
        User memory newUser = User(name, age);

        users[msg.sender] = newUser;
    }

    function getUser(address user) public view returns (User memory) {
        return users[user];
    }
}  