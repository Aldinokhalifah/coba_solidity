// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract TodoList_MultiUser {
    
    struct Todo {
        uint id;
        string text;
        bool completed;
        bool exists;
    }

    event TodoAdded(string text);
    event TodoUpdated(uint id, string text);
    event TodoDeleted(uint id);

    mapping(address => mapping(uint => Todo)) todos;
    mapping(address => uint[]) todoIds;
    mapping(address => uint) nextTodoId;

    function addTodo(string memory text) public {
        require(bytes(text).length > 0, "Text kosong");

        uint id = nextTodoId[msg.sender];

        todos[msg.sender][id] = Todo(id, text, false, true);

        todoIds[msg.sender].push(id);

        emit TodoAdded(text);

        nextTodoId[msg.sender]++;
    }

    function getTodo(uint id) public view returns(Todo memory) {
        require(todos[msg.sender][id].exists, "ID tidak ditemukan");

        return todos[msg.sender][id];
    }

    function getMyTodos() public view returns(Todo[] memory) {
        uint length = todoIds[msg.sender].length;
        Todo[] memory allData = new Todo[](length);

        for(uint i =0; i < length; i++) {
            uint id = todoIds[msg.sender][i];
            allData[i] = todos[msg.sender][id];
        }

        return allData;
    }

    function updateTodo(uint id, string memory newText) public {
        require(todos[msg.sender][id].exists, "ID tidak ditemukan");
        require(bytes(newText).length > 0, "Text kosong");

        todos[msg.sender][id].text = newText;

        emit TodoUpdated(id, newText);
    }

    function toggleComplete(uint id) public {
        require(todos[msg.sender][id].exists, "ID tidak ditemukan");

        todos[msg.sender][id].completed = !todos[msg.sender][id].completed;
    }

    function deleteTodo(uint id) public {
        require(todos[msg.sender][id].exists, "ID tidak ditemukan");

        delete todos[msg.sender][id];

        uint length = todoIds[msg.sender].length;

        for (uint i = 0; i < length; i++) {
            if (todoIds[msg.sender][i] == id) {
                todoIds[msg.sender][i] = todoIds[msg.sender][length - 1];
                todoIds[msg.sender].pop();
                break;
            }
        }

        emit TodoDeleted(id);
    }
}