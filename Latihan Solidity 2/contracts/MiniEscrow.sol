// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract MiniEscrow {
    uint public nextId;
    
    struct Escrow {
        uint id;
        address buyer;
        address seller;
        uint amount;
        bool isPaid;
        bool isReleased;
        bool isRefund;
    }

    Escrow[] public listEscrows;

    mapping(uint => Escrow) public escrows;

    event EscrowCreated(uint id, address buyer, address seller, uint amount);
    event Released(uint id);
    event Refunded(uint id);

    function createEscrow(address _seller) public payable {
        require(msg.sender != _seller, "Tidak boleh transaksi sendiri");
        require(msg.value > 0, "Jumlah harus > 0");

        escrows[nextId] = Escrow({
            id: nextId,
            buyer: msg.sender,
            seller: _seller,
            amount: msg.value,
            isPaid: true,
            isReleased: false,
            isRefund: false
        });

        emit EscrowCreated(nextId, msg.sender, _seller, msg.value);
        nextId++;
    }

    function release(uint id) public {
        Escrow storage e = escrows[id];

        require(msg.sender == e.seller);
        require(e.isPaid && !e.isReleased && !e.isRefund);

        e.isReleased = true;
        payable(e.seller).transfer(e.amount);

        emit Released(id);
    }

    function refund(uint id) public {
        Escrow storage e = escrows[id];

        require(msg.sender == e.buyer);
        require(e.isPaid && !e.isReleased && !e.isRefund);

        e.isRefund = true;
        payable(e.buyer).transfer(e.amount);

        emit Refunded(id);
    }
}