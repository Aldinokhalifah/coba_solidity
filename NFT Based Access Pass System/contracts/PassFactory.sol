// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import './AccessPassERC721.sol';
contract PassFactory {
    address[] public allPasses;
    mapping(address => address[]) public creatorToPasses;
    
    event PassCreated(address indexed creator, address passAddress);

    function createPass(string memory name, string memory symbol, string memory baseURI) external returns(address) {
        require(bytes(name).length > 0, "NAME IS NULL");
        require(bytes(symbol).length > 0, "SYMBOL IS NULL");
        require(bytes(baseURI).length > 0);

        AccessPassERC721 pass = new AccessPassERC721(name, symbol, baseURI);

        creatorToPasses[msg.sender].push(address(pass));

        allPasses.push(address(pass));

        emit PassCreated(msg.sender, address(pass));

        pass.transferOwnership(msg.sender);

        return address(pass);
    }

    function getPassesByCreator(address creator) external view returns (address[] memory) {
        return creatorToPasses[creator];
    }

    function totalPasses() external view returns (uint256) {
        return allPasses.length;
    }
}