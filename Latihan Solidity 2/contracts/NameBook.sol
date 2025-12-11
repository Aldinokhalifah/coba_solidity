// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract NameBook {
    struct Mahasiswa {
        uint id;
        string name;
    }

    event AddName(uint id, string name);
    event UpdateName(uint id, string name);
    event DeleteName(uint id);

    uint[] public mahasiswaId;
    mapping(uint => Mahasiswa) public listMahasiswa;

    function addName(uint _id, string memory _name) public {
        require(bytes(_name).length > 0, "Nama tidak boleh kosong");
        require(_id > 0, "ID tidak boleh nol");
        require(listMahasiswa[_id].id == 0, "ID sudah dipakai");

        listMahasiswa[_id] = Mahasiswa(_id, _name);
        mahasiswaId.push(_id);

        emit AddName(_id, _name);
    }

    function getName(uint _id) public view returns(string memory) {
        require(listMahasiswa[_id].id != 0, "ID tidak ada");
        return listMahasiswa[_id].name;
    }

    function getAll() public view returns(Mahasiswa[] memory) {
        uint length = mahasiswaId.length;
        Mahasiswa[] memory allData = new Mahasiswa[](length);

        for(uint i = 0; i < length; i++) {
            uint id = mahasiswaId[i];
            allData[i] = listMahasiswa[id];
        }

        return allData;
    }

    function updateMahasiswa(uint _id, string memory newName) public {
        require(listMahasiswa[_id].id != 0, "ID tidak ada");

        listMahasiswa[_id].name = newName;

        emit UpdateName(_id, newName);
    }

    function deleteMahasiswa(uint _id) public {
        require(listMahasiswa[_id].id != 0, "ID tidak ada");

        delete listMahasiswa[_id];

        uint length = mahasiswaId.length;
        for(uint i = 0; i < length; i++) {
            if(mahasiswaId[i] == _id) {
                mahasiswaId[i] = mahasiswaId[length - 1];
                mahasiswaId.pop();
                break;
            }
        }

        emit DeleteName(_id);
    }
}
