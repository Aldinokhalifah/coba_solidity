// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >0.8.0;

contract UserList {
    struct User {
        string nama;
        uint umur;
    }

    User[] public daftarUser;

    function tambahUser(string memory _nama, uint _umur) public {
        daftarUser.push(User(_nama, _umur));
    }

    function getUser(uint index) view public returns(string memory, uint) {
        User memory user = daftarUser[index];
        return (user.nama, user.umur);
    }

    function getJumlahUser() view public returns(uint) {
        return daftarUser.length;
    }

    function hapusUserTerkini() public {
        daftarUser.pop();
    }
}