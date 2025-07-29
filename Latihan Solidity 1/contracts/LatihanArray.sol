// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >0.8.0;

contract LatihanArray {
    uint[] public numbers;

    function tambahAngka(uint angka) public {
        numbers.push(angka);
    }

    function hapusAngkaTerakhir() public {
        numbers.pop();
    }

    function jumlahSemua() view public returns(uint) {
        uint hasilAkhir = 0;
        for( uint i = 0; i < numbers.length; i++) {
            hasilAkhir += numbers[i];
        }
        return hasilAkhir;
    }

    function cariAngka(uint angka) view public returns(bool) {
        for( uint i = 0; i < numbers.length; i++) {
            if (numbers[i] == angka) {
                return true;
            }
        }
        return false;
    }

    function getAngka(uint index) view public returns(uint) {
        return numbers[index];
    }
}