// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.2 <=0.9.0;

contract LatihanFungsi {
    string greet;
    uint a;
    uint b;

    function setGreeting(string memory _greet) public {
        greet = _greet;
    }
    
    function getGreeting() public view returns (string memory) {
        return greet;
    }

    function kali(uint _a, uint _b) public pure returns (uint) {
        return _a * _b;
    }

    function bagi(uint _a, uint _b) public pure returns (uint) {
        require(_b != 0, "Tidak boleh dibagi 0");
        return _a / _b;
    }


}