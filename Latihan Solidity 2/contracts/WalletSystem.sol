// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract WalletSystem {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    event UserRegistered(address user);
    event TopUp(address user, uint amount);
    event WithdrawRequested(uint id, address user, uint amount);
    event WithdrawApproved(uint id);
    event WithdrawProcessed(uint id, address user, uint amount);
    event WithdrawRejected(uint id);
    event WithdrawCancelled(uint id);



    struct User {
        address user;
        uint balance;
        bool isRegistered;
    }

    struct WithdrawRequest {
        uint id;
        address user;
        uint amount;
        bool approved;
        bool processed;
        bool exists;
    }

    mapping(address => User) users;
    mapping(uint => WithdrawRequest) requests;
    uint[] requestIds;
    uint nextRequestId;

    function register() public {
        require(!users[msg.sender].isRegistered, "User sudah terdaftar");

        users[msg.sender] = User(msg.sender, 0, true);

        emit UserRegistered(msg.sender);
    }

    function topUp() public payable {
        require(users[msg.sender].isRegistered, "User tidak terdaftar");
        require(msg.value > 0, "Jumlah harus lebih dari 0"); 

        users[msg.sender].balance += msg.value;

        emit TopUp(msg.sender, msg.value);
    }

    function requestWithdraw(uint amount) public {
        require(users[msg.sender].isRegistered, "User tidak terdaftar");
        require(amount > 0, "Jumlah harus lebih dari 0");
        require(amount <= users[msg.sender].balance, "Jumlah tidak boleh lebih dari saldo");

        requests[nextRequestId] = WithdrawRequest({
            id: nextRequestId,
            user: msg.sender,
            amount: amount,
            approved: false,
            processed: false,
            exists: true
        });

        requestIds.push(nextRequestId);

        emit WithdrawRequested(nextRequestId, msg.sender, amount);

        nextRequestId++;
    }

    function approveWithdraw(uint requestId) public onlyOwner() {
        require(requests[requestId].exists, "Permintaan tidak ada");
        require(!requests[requestId].processed, "Permintaan sudah diproses");

        requests[requestId].approved = true;

        emit WithdrawApproved(requestId);
    }

    function rejectWithdraw(uint requestId) public onlyOwner() {
        require(requests[requestId].exists, "Permintaan tidak ada");
        require(!requests[requestId].processed, "Permintaan sudah diproses");

        requests[requestId].processed = true;
        requests[requestId].approved = false;

        emit WithdrawRejected(requestId);

    }

    function processWithdraw(uint requestId) public onlyOwner() {
        WithdrawRequest storage r = requests[requestId];

        require(r.exists, "Permintaan tidak ada");
        require(r.approved, "Permintaan belum disetujui");
        require(!r.processed, "Permintaan sudah diproses");
        require(address(this).balance >= r.amount, "Saldo anda kurang");

        r.processed = true;
        users[r.user].balance -= r.amount;
        payable(r.user).transfer(r.amount);

        emit WithdrawProcessed(requestId, r.user, r.amount);
    }

    function cancelWithdraw(uint requestId) public {
        WithdrawRequest storage r = requests[requestId];

        require(r.exists, "Request tidak ada");
        require(r.user == msg.sender, "Bukan request kamu");
        require(!r.processed, "Sudah diproses");

        r.processed = true;

        emit WithdrawCancelled(requestId);
    }

    function getMyRequests() public view returns (WithdrawRequest[] memory) {
        uint count = 0;

        for (uint i = 0; i < requestIds.length; i++) {
            if (requests[requestIds[i]].user == msg.sender) {
                count++;
            }
        }

        WithdrawRequest[] memory myRequests = new WithdrawRequest[](count);
        uint index = 0;

        for (uint i = 0; i < requestIds.length; i++) {
            uint id = requestIds[i];
            if (requests[id].user == msg.sender) {
                myRequests[index] = requests[id];
                index++;
            }
        }

        return myRequests;
    }


    function getRequestStatus(uint requestId) public view returns(bool, bool) {
        require(requests[requestId].exists, "Permintaan tidak ada");

        return (requests[requestId].approved, requests[requestId].processed);
    }


    function getMyBalance() public view returns(uint) {
        require(users[msg.sender].isRegistered, "User tidak terdaftar");

        return users[msg.sender].balance;
    }  

    function getAllRequest() public view returns(WithdrawRequest[] memory) {
        uint length = requestIds.length;

        WithdrawRequest[] memory allData = new WithdrawRequest[](length);

        for(uint i = 0; i < length; i++ ) {
            uint id = requestIds[i];
            allData[i] = requests[id];
        }

        return allData;
    }
}