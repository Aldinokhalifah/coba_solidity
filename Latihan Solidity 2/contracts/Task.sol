// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >0.8.0;

contract Task {
    address public owner;

    constructor () {
        owner = msg.sender;
    }

    struct Tasks {
        string deskripsi;
        bool selesai;
    }

    mapping(address => Tasks[]) tugas;

    function setTask( address  _owner, string memory _deskripsi, bool _selesai) public {
        tugas[_owner].push(Tasks(_deskripsi, _selesai));
    }

    function setDoneTask(uint id, bool _selesai) public {
        tugas[owner][id].selesai = _selesai;
    }

    function getTask(address _owner) view public returns (string[] memory, bool[] memory) {
        require(_owner == owner, "TASK_NOT_FOUND");

        uint length = tugas[_owner].length;
        string[] memory deskripsi = new string[](length);
        bool[] memory selesaiList = new bool[](length);

        for(uint i = 0; i < length; i++) {
            deskripsi[i] = tugas[_owner][i].deskripsi;
            selesaiList[i] = tugas[_owner][i].selesai;
        }
        return (deskripsi, selesaiList);
    }
}