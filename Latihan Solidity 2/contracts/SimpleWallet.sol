// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract SimpleWallet {

    struct Transaction {
        address from;
        uint amount;
        uint timestamp;
    }

    mapping(address => uint) private saldo;
    mapping(address => Transaction[]) private history;

    event Deposited(address indexed user, uint amount);

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        require(msg.sender != address(0), "Invalid sender");

        saldo[msg.sender] += msg.value;

        history[msg.sender].push(
            Transaction({
                from: msg.sender,
                amount: msg.value,
                timestamp: block.timestamp
            })
        );

        emit Deposited(msg.sender, msg.value);
    }

    function getSaldo(address user) public view returns (uint) {
        return saldo[user];
    }

    function getTransactionCount(address user) public view returns (uint) {
        return history[user].length;
    }

    function getTransactionByIndex(address user, uint index) public view returns (Transaction memory)
    {
        require(index < history[user].length, "Index out of bounds");
        return history[user][index];
    }
}
