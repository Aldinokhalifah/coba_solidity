// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IAccessPass {
    function ownerOf(uint256 tokenId) external view returns (address);
    function isValid(uint256 tokenId) external view returns (bool);
}