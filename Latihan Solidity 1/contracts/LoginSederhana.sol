// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0;

contract LoginSederhana {
    string private username;
    string private password;

    function setAkun(string memory _username, string memory _password) public {
        require(bytes(_username).length > 0, "Username kosong!");
        require(bytes(_password).length > 0, "Password kosong!");

        username = _username;
        password = _password;

    }

    function login(string memory _username, string memory _password) public view returns(bool) {
        return keccak256(bytes(username)) == keccak256(bytes(_username)) && 
                keccak256(bytes(password)) == keccak256(bytes(_password));
    }
}