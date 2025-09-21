// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract Voting {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    uint public totalCandidates;

    mapping(address => bool) public hasVoted;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    function addCandidate(string memory _name) public onlyOwner {
        totalCandidates++;
        candidates[totalCandidates] = Candidate(totalCandidates, _name, 0);
    }

    function vote(uint candidateId) public {
        require(candidateId > 0 && candidateId <= totalCandidates, "Candidate does not exist");
        require(!hasVoted[msg.sender], "You already voted");

        candidates[candidateId].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getCandidate(uint candidateId) public view returns (uint, string memory, uint) {
        require(candidateId > 0 && candidateId <= totalCandidates, "Candidate does not exist");
        Candidate memory candidate = candidates[candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
}
