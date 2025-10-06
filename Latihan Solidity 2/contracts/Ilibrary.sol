// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >0.8.0;

interface Ilibrary {
    function addBook(string memory title) external;
    function borrowBook(uint id) external;
    function returnBook(uint id) external;
    function getBorrowedBooks(address user) external view returns(uint[] memory, string[] memory);
}