// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >0.8.0;

contract Student {

    struct Students {
        string nama;
        string jurusan;
        uint tahun_masuk;
    }

    mapping(uint => Students) NIM;

    function setStudent(uint _nim, string memory _nama, string memory _jurusan, uint _tahun_masuk) external {
        NIM[_nim] = Students(_nama, _jurusan, _tahun_masuk);
    }

    function getStudent(uint _nim) external view returns(string memory, string memory, uint) {
        
        require(bytes(NIM[_nim].nama).length != 0, "STUDENT_NOT_FOUND");

        Students memory murid = NIM[_nim];
        return (murid.nama, murid.jurusan, murid.tahun_masuk);
    }
}