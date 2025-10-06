// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >0.8.0;

import "./Ilibrary.sol";

contract RentalBook is Ilibrary {

    address public owner;

    struct Book {
        uint id;
        string title;
        bool isAvailable;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    mapping(uint => Book) public books;
    mapping(address => uint[]) public borrowedBooks;
    uint public bookIdCounter;

    function addBook(string memory title) override onlyOwner external  {
        bookIdCounter += 1;
        books[bookIdCounter] = Book(bookIdCounter, title, true);
    }

    function borrowBook(uint id) override external {
        require(books[id].id != 0, "BOOK NOT FOUND");
        require(books[id].isAvailable == true, "BOOK IS BORROWED");

        books[id].isAvailable = false;
        borrowedBooks[msg.sender].push(id);
    }

    function returnBook(uint id) override external {
        require(books[id].id != 0 , "ID NOT FOUND");
        bool hasBook = false;
        for (uint i = 0; i < borrowedBooks[msg.sender].length; i++) {
            if (borrowedBooks[msg.sender][i] == id) {
                hasBook = true;
                break;
            }
        }
        require(hasBook, "USER NOT ALLOWED TO RETURN THIS BOOK");

        books[id].isAvailable = true;
    }

    function getBorrowedBooks(address user) override external view returns(uint[] memory, string[] memory) {
        require(borrowedBooks[user].length > 0, "BOOK NOT FOUND");

        uint length = borrowedBooks[user].length;
        string[] memory titleBook = new string[](length);
        uint[] memory idBook = new uint[](length);

        for(uint i = 0; i < length; i++) {
            uint bookId = borrowedBooks[user][i];
            idBook[i] = bookId;
            titleBook[i] = books[bookId].title;
        } 
        return (idBook, titleBook); 
    }
}