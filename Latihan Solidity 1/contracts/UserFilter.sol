// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0;

contract UserFilter {
    struct User {
        string name;
        uint age;
    }

    User[] public daftarUser;

    function tambahUser(string memory _name, uint _age) public {
        daftarUser.push(User(_name, _age));
    }

    function getUserDewasa() public view returns(string[] memory, uint[] memory) {
        uint count = 0;
        for(uint i = 0; i < daftarUser.length; i++) {
            if(daftarUser[i].age >= 17) {
                count++;
            }
        }

        string[] memory names = new string[](count);
        uint[] memory ages = new uint[](count);
        uint index = 0;
        for(uint i = 0; i < daftarUser.length; i++) {
            if(daftarUser[i].age >= 17) {
                names[index] = daftarUser[i].name;
                ages[index] = daftarUser[i].age;
                index++;
            }
        }
        return (names, ages);
    }

    

    
}