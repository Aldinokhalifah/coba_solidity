// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract CollaborativeAccess {
    uint public activationDelay;
    uint public approvalPercentage;
    enum Role { MEMBER, ADMIN }
    uint public adminCount;

    struct AccessRequest {
        uint id;
        address requester;
        string resource;
        uint approvals;
        uint createdAt;
        bool activated;
        bool cancelled;
        uint approvalPercentageAtCreation;
        uint memberCountAtCreation;
    }

    event ApprovalRevoked(uint id, address member);
    event RequestCancelled(uint id);
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event GovernanceUpdated(uint percentage, uint delay);
    event AccessActivated(uint requestId);



    mapping(address => Role) public roles;
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
            roles[members[i]] = Role.MEMBER;
        }

        roles[members[0]] = Role.ADMIN;
        adminCount = 1;
    }

    function promoteToAdmin(address member) external {
        require(roles[msg.sender] == Role.ADMIN, "BUKAN ADMIN");
        require(isMember[member], "BUKAN MEMBER");
        require(roles[member] != Role.ADMIN, "SUDAH ADMIN");

        roles[member] = Role.ADMIN;
        adminCount++;
    }

    function addMember(address newMember) external {
        require(roles[msg.sender] == Role.ADMIN, "CALLER BUKAN ADMIN");
        require(newMember != address(0), "ADDRESS TIDAK VALID");
        require(isMember[newMember] == false, "SUDAH MENJADI MEMBER");

        isMember[newMember] = true;
        roles[newMember] = Role.MEMBER;
        members.push(newMember);

        emit MemberAdded(newMember);
    }

    function removeMember(address member) external {
        require(roles[msg.sender] == Role.ADMIN, "CALLER BUKAN ADMIN");
        require(isMember[member], "TARGET BUKAN MEMBER");

        if (roles[member] == Role.ADMIN) {
            require(adminCount > 1, "ADMIN TIDAK BOLEH HABIS");
            adminCount--;
        }

        isMember[member] = false;
        roles[member] = Role.MEMBER;

        // remove dari array
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == member) {
                members[i] = members[members.length - 1];
                members.pop();
                break;
            }
        }

        emit MemberRemoved(member);
    }

    function requestAccess(string calldata resource) external {
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(bytes(resource).length > 0, "RESOURCE KOSONG");

        requests.push(AccessRequest(nextRequestId, msg.sender, resource, 0, block.timestamp, false, false, approvalPercentage, members.length));

        nextRequestId++;
    }

    function approveAccess(uint requestId) external {
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(requestId < requests.length, "REQUEST TIDAK ADA");
        require(!hasApproved[requestId][msg.sender], "SUDAH APPROVED");
        require(!requests[requestId].activated, "REQUEST SUDAH AKTIF");
        require(!requests[requestId].cancelled, "REQUEST DIBATALKAN");
        require(requests[requestId].requester != msg.sender, "REQUESTER TIDAK BOLEH APPROVE");

        hasApproved[requestId][msg.sender] = true;
        requests[requestId].approvals++;
    }

    function activateAccess(uint requestId) external {
        uint requiredApprovals = (members.length * approvalPercentage + 99) / 100;
        require(isMember[msg.sender], "BUKAN MEMBER");
        require(requestId < requests.length);
        require(!requests[requestId].activated, "REQUEST SUDAH AKTIF");
        require(requests[requestId].approvals >= requiredApprovals);
        require(block.timestamp >= requests[requestId].createdAt + activationDelay);
        require(!requests[requestId].cancelled, "REQUEST DIBATALKAN");
        require(requiredApprovals >= 1, "APPROVAL MINIMAL 1");


        requests[requestId].activated = true;

        emit AccessActivated(requestId);
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

    function updateApprovalPercentage(uint newPercentage) external {
        require(roles[msg.sender] == Role.ADMIN, "CALLER BUKAN ADMIN");
        require(newPercentage > 0 && newPercentage <= 100, "PERSENTASE TIDAK VALID");

        approvalPercentage = newPercentage;

        emit GovernanceUpdated(newPercentage, activationDelay);
    }

    function updateActivationDelay(uint newDelay) external {
        require(roles[msg.sender] == Role.ADMIN, "CALLER BUKAN ADMIN");

        activationDelay = newDelay;

        emit GovernanceUpdated(approvalPercentage, newDelay);
    }
}