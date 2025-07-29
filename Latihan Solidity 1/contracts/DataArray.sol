// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0;

contract DataArray {
    string[] public name;

    function tambahNama(string memory _name) public {
        name.push(_name);
    }

    function getJumlahNama() public view returns (uint) {
        return name.length;
    }

    function getSemuaNama() public view returns (string[] memory) {
        return name;
    }

    // Mengambil nama berdasarkan index
    function getIndexNama(uint index) public view returns (string memory) {
        require(index < name.length, "Index tidak valid!");
        return name[index];
    }
}