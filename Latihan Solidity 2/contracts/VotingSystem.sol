// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract VotingSystem {
    address public admin;
    uint public nextId;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "KAMU BUKAN ADMIN");
        _;
    }

    event CandidateAdded(uint id, string name);
    event Voted(address voter, uint candidateId);

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint voteCandidateId;
    }

    Candidate[] public candidates;

    mapping(address => Voter) voters;

    function addCandidate(string memory _name) public onlyAdmin {
        require(bytes(_name).length > 0, "NAMA TIDAK BOLEH KOSONG");

        Candidate memory newCandidate = Candidate({
            id: nextId,
            name: _name,
            voteCount: 0
        });

        candidates.push(newCandidate);

        emit CandidateAdded(nextId, _name);

        nextId++;
    }

    function vote(uint candidateId) public {
        require(voters[msg.sender].hasVoted == false, "TIDAK BOLEH MELAKUKAN PEMILIHAN LEBIH DARI SEKALI");
        require(candidateId < candidates.length, "CANDIDATE TIDAK TERDAFTAR");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].voteCandidateId = candidateId;

        candidates[candidateId].voteCount++;

        emit Voted(msg.sender, candidateId);
    }

    function getCandidates() public view returns(Candidate[] memory) {
        return candidates;
    }

    function getResult() public view returns(string memory _name, uint _voteCount) {
        require(candidates.length > 0, "TIDAK ADA CANDIDATES TERDAFTAR");

        string memory nameHighestScore = candidates[0].name;
        uint highestScore = candidates[0].voteCount;

        for(uint i = 1; i < candidates.length; i++) {
            if(candidates[i].voteCount > highestScore) {
                highestScore = candidates[i].voteCount;
                nameHighestScore = candidates[i].name;
            }
        }

        return(nameHighestScore, highestScore);
    } 

    function getMyVote(address _voter) public view returns(uint _candidateId, string memory _name, uint _voteCount) {
        require(voters[_voter].hasVoted == true, "KAMU BELUM MELAKUKAN PEMILIHAN");

        uint cid = voters[_voter].voteCandidateId;
        Candidate memory c = candidates[cid];
        return (c.id, c.name, c.voteCount);
    }
}