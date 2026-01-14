// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract CollaborativeAccess {
    uint public approvalThreshold;
    uint public activationDelay;

    struct AccessRequest {
        uint id;
        address requester;
        string resource;
        uint approvals;
        uint createdAt;
        bool activated;
    }

    mapping(address => bool) public isMember;
    address[] public members;
    mapping(uint => mapping(address => bool)) public hasApproved;
    AccessRequest[] public requests;
    uint private nextRequestId;

    constructor(address[] memory _members, uint _threshold, uint _delay) {
        approvalThreshold = _threshold;
        activationDelay = _delay;

        for (uint i = 0; i < _members.length; i++) {
            isMember[_members[i]] = true;
            members.push(_members[i]);
        }
    }

    function requestAccess(string calldata resource) external {
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(bytes(resource).length > 0, "RESOURCE KOSONG");

        requests.push(AccessRequest(nextRequestId, msg.sender, resource, 0, block.timestamp, false));

        nextRequestId++;
    }

    function approveAccess(uint requestId) external {
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(requestId < requests.length, "REQUEST TIDAK ADA");
        require(!hasApproved[requestId][msg.sender], "SUDAH APPROVED");
        require(!requests[requestId].activated, "REQUEST SUDAH AKTIF");

        hasApproved[requestId][msg.sender] = true;
        requests[requestId].approvals++;
    }

    function activateAccess(uint requestId) external {
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(requestId < requests.length);
        require(!requests[requestId].activated, "REQUEST SUDAH AKTIF");
        require(requests[requestId].approvals >= approvalThreshold);
        require(block.timestamp >= requests[requestId].createdAt + activationDelay);

        requests[requestId].activated = true;
    }
}