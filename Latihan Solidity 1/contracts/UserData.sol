// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 <=0.9.0;

contract UserData {
    string public name;
    uint public age;

    function setUserData( string memory _name, uint  _age) public {
        name = _name;
        age = _age;
    }

    function getUserData() public view returns(string memory, uint) {
        return (name, age);
    }

    function isAdult(uint _age) public pure returns(bool) {
        if (_age >= 17) {
            return true;
        }
        return false;
    }

    function cekNama(string memory _name) public view returns(bool) {
        if (keccak256(bytes(name)) == keccak256(bytes(_name))) {
            return true;
        }
        return false;
    }
}