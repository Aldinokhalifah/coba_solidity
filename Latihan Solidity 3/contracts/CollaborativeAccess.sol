// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract CollaborativeAccess {
    uint public activationDelay;
    uint public approvalPercentage;

    struct AccessRequest {
        uint id;
        address requester;
        string resource;
        uint approvals;
        uint createdAt;
        bool activated;
        bool cancelled;
    }

    event ApprovalRevoked(uint id, address member);
    event RequestCancelled(uint id);


    mapping(address => bool) public isMember;
    address[] public members;
    mapping(uint => mapping(address => bool)) public hasApproved;
    AccessRequest[] public requests;
    uint private nextRequestId;

    constructor(address[] memory _members, uint _delay, uint _percentage) {
        require(_percentage > 0 && _percentage <= 100, "PERCENTAGE INVALID");
        require(_members.length > 0, "MEMBER KOSONG");

        activationDelay = _delay;
        approvalPercentage = _percentage;

        for (uint i = 0; i < _members.length; i++) {
            isMember[_members[i]] = true;
            members.push(_members[i]);
        }
    }

    function requestAccess(string calldata resource) external {
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(bytes(resource).length > 0, "RESOURCE KOSONG");

        requests.push(AccessRequest(nextRequestId, msg.sender, resource, 0, block.timestamp, false, false));

        nextRequestId++;
    }

    function approveAccess(uint requestId) external {
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(requestId < requests.length, "REQUEST TIDAK ADA");
        require(!hasApproved[requestId][msg.sender], "SUDAH APPROVED");
        require(!requests[requestId].activated, "REQUEST SUDAH AKTIF");
        require(!requests[requestId].cancelled, "REQUEST DIBATALKAN");

        hasApproved[requestId][msg.sender] = true;
        requests[requestId].approvals++;
    }

    function activateAccess(uint requestId) external {
        uint requiredApprovals = (members.length * approvalPercentage) / 100;
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(requestId < requests.length);
        require(!requests[requestId].activated, "REQUEST SUDAH AKTIF");
        require(requests[requestId].approvals >= requiredApprovals);
        require(block.timestamp >= requests[requestId].createdAt + activationDelay);
        require(!requests[requestId].cancelled, "REQUEST DIBATALKAN");
        require(requiredApprovals >= 1, "APPROVAL MINIMAL 1");


        requests[requestId].activated = true;
    }

    function revokeApproval(uint requestId) external {
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(requestId < requests.length, "REQUEST TIDAK ADA");
        require(hasApproved[requestId][msg.sender], "BELUM APPROVE");
        require(!requests[requestId].activated, "REQUEST SUDAH AKTIF");
        require(!requests[requestId].cancelled, "REQUEST DIBATALKAN");

        hasApproved[requestId][msg.sender] = false;
        requests[requestId].approvals--;

        emit ApprovalRevoked(requestId, msg.sender);
    }

    function cancelRequest(uint requestId) external {
        require(requestId < requests.length, "REQUEST TIDAK ADA");
        require(requests[requestId].requester == msg.sender, "CALLER HARUS REQUESTER");
        require(!requests[requestId].activated, "REQUEST SUDAH AKTIF");
        require(!requests[requestId].cancelled, "REQUEST DIBATALKAN");

        requests[requestId].cancelled = true;

        emit RequestCancelled(requestId);
    }
}