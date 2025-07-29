// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >0.8.0;

contract Book {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Books {
        string title;
        string author;
        uint year;
    }

    mapping( address => Books[]) public buku;

    function setBook(string memory _title, string memory _author, uint _year) public {
        buku[owner].push(Books(_title, _author, _year));
    }

    function getBook(address user, uint index) public view returns(string memory, string memory, uint) {
        require(index < buku[user].length, "BOOK_NOT_FOUND");

        Books memory book = buku[user][index];
        return (book.title, book.author, book.year);
    }
}