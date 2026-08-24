// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract AdminSystem {
    address public admin;

    struct Admin {
        uint id;
        address addressAdmin;
        string name;
    }

    Admin[] public listAdmins;

    event AdminChanged(
        address indexed oldAdmin,
        address indexed newAdmin
    );

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "KAMU BUKAN ADMIN");
        _;
    }

    function changeAdmin(Admin memory newAdmin) public onlyAdmin {
        address oldAdmin = admin;

        admin = newAdmin.addressAdmin;
        listAdmins.push(newAdmin);

        emit AdminChanged(oldAdmin, newAdmin.addressAdmin);
    }

    function getAdmins() public view returns (Admin[] memory) {
        return listAdmins;
    }
}