// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract TimeLockedSharedWallet{
    uint lockTime;
    uint minApprovals;
    uint private seq;
    
    struct WithdrawalRequest {
        uint id;
        uint amount;
        uint approvals;
        bool executed;
    }

    event Deposited(address indexed member, uint amount);
    event WithdrawalRequested(uint indexed id, uint amount);
    event WithdrawalApproved(uint indexed id, address indexed member);
    event WithdrawalExecuted(uint indexed id, address indexed executor, uint amount);


    address[] members;
    WithdrawalRequest[] requests;
    mapping(address => bool) checkMember;
    mapping(uint => mapping(address => bool)) approvalTracking;

    function deposit() public payable{
        require(checkMember[msg.sender], "BUKAN MEMBER");
        require(msg.value > 0, "JUMLAH HARUS LEBIH DARI 0");

        emit Deposited(msg.sender, msg.value);
    }

    function createWithdrawalRequest(uint amount) public {
        require(checkMember[msg.sender], "BUKAN MEMBER");
        require(amount > 0, "JUMLAH HARUS LEBIH DARI 0");

        requests.push(WithdrawalRequest(seq, amount, 0, false));

        emit WithdrawalRequested(seq, amount);

        seq++;
    }

    function approveWithdrawal(uint requestId) public {
        require(checkMember[msg.sender], "BUKAN MEMBER");
        require(requestId < requests.length, "REQUEST TIDAK ADA");
        require(!requests[requestId].executed, "REQUEST SUDAH DIEKSEKUSI");
        require(!approvalTracking[requestId][msg.sender], "SUDAH APPROVE");

        approvalTracking[requestId][msg.sender] = true;
        requests[requestId].approvals++;

        emit WithdrawalApproved(requestId, msg.sender);
    }


    function executeWithdrawal(uint requestId) public {
        require(checkMember[msg.sender], "BUKAN MEMBER");
        require(requestId < requests.length, "REQUEST TIDAK ADA");

        WithdrawalRequest storage req = requests[requestId];

        require(!req.executed, "SUDAH DIEKSEKUSI");
        require(block.timestamp >= lockTime, "MASIH DI-LOCK");
        require(req.approvals >= minApprovals, "APPROVAL KURANG");
        require(address(this).balance >= req.amount, "SALDO KURANG");

        req.executed = true;

        (bool success, ) = msg.sender.call{value: req.amount}("");
        require(success, "TRANSFER GAGAL");

        emit WithdrawalExecuted(requestId, msg.sender, req.amount);
    }

}