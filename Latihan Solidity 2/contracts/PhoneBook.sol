// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.8.0;

contract PhoneBook {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Contact {
        string name;
        string phoneNumber;
    }

    mapping(address => Contact) contactUser;

    function setMyContact(string memory _name, string memory _phoneNumber) public {
        contactUser[msg.sender] = Contact(_name, _phoneNumber);
    }

    function getMyContact(address user) public view returns (string memory, string memory)  {

        require(bytes(contactUser[user].name).length > 0, "USER NOT FOUND");

        Contact memory contact = contactUser[user];
        return(contact.name, contact.phoneNumber);
    }
}