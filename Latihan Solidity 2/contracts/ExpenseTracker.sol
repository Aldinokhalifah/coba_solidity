// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract ExpenseTracker {
    uint public nextId;

    struct Expense {
        uint id;
        string title;
        uint amount;
        string category;
        uint timestamp;
        bool exists;
    }

    event ExpenseAdded(uint id, string title, uint amount, string category);
    event ExpenseUpdated(uint id);
    event ExpenseDeleted(uint id);

    uint[] public expenseIds;
    mapping(uint => Expense) public expenses;

    function addExpense(string memory title, uint amount, string memory category) public {
        require(bytes(title).length > 0, "Title kosong");
        require(amount > 0, "Amount kosong");
        require(bytes(category).length > 0, "Category kosong");

        expenses[nextId] = Expense(
            nextId,
            title,
            amount,
            category,
            block.timestamp,
            true
        );

        expenseIds.push(nextId);
        emit ExpenseAdded(nextId, title, amount, category);

        nextId++;
    }

    function getExpense(uint id) public view returns(Expense memory) {
        require(expenses[id].exists, "ID tidak ditemukan");
        return expenses[id];
    }

    function getAllExpenses() public view returns(Expense[] memory) {
        uint length = expenseIds.length;
        Expense[] memory allData = new Expense[](length);

        for(uint i = 0; i < length; i++) {
            uint id = expenseIds[i];
            allData[i] = expenses[id];
        }

        return allData;
    }

    function updateExpense(uint id, string memory newTitle, uint newAmount, string memory newCategory) public {
        require(expenses[id].exists, "ID tidak ditemukan");

        expenses[id].title = newTitle;
        expenses[id].amount = newAmount;
        expenses[id].category = newCategory;

        emit ExpenseUpdated(id);
    }

    function deleteExpense(uint id) public {
        require(expenses[id].exists, "ID tidak ditemukan");

        delete expenses[id];

        uint length = expenseIds.length;
        for(uint i = 0; i < length; i++) {
            if(expenseIds[i] == id) {
                expenseIds[i] = expenseIds[length - 1];
                expenseIds.pop();
                break;
            }
        }

        emit ExpenseDeleted(id);
    }
}