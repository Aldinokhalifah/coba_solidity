// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

/// @title AccessPassERC721 - NFT access pass with expiry and optional soulbound
/// @notice Minimal, production-oriented ERC721 pass contract for V1 MVP
/// @dev Uses OpenZeppelin contracts. Admin (owner) mints, sets expiry, revokes, etc.

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract AccessPassERC721 is ERC721, Ownable, ReentrancyGuard {
    mapping(uint256 => uint64) private _expiry;
    mapping(uint256 => bool) private _soulbound;
    mapping(uint256 => string) private _tokenURIs;

    string private _baseTokenURI;
    uint256 private _nextId;

    event PassMinted(address indexed to, uint256 indexed tokenId, uint64 expiry);
    event PassRevoked(uint256 indexed tokenId, address indexed revokedBy);
    event ExpiryExtended(uint256 indexed tokenId, uint64 oldExpiry, uint64 newExpiry);
    event SoulboundSet(uint256 indexed tokenId, bool soulbound);

    constructor(string memory name_, string memory symbol_, string memory baseURI_) ERC721(name_, symbol_) {
        _baseTokenURI = baseURI_;
    }

    modifier onlyExisting(uint256 tokenId) {
        require(_exists(tokenId), "AccessPass: nonexistent token");
        _;
    }

    function mint(address to, uint64 expiry, bool soulbound, string memory uri) external onlyOwner returns(uint256) {
        require(to != address(0), "ADDRESS IS NULL");
        require(expiry == 0 || expiry > block.timestamp, "INVALID EXPIRY");

        _nextId++;

        uint256 newId = _nextId;

        _expiry[newId] = expiry;
        _soulbound[newId] = soulbound;

        if(bytes(uri).length > 0) {
            _tokenURIs[newId] = uri;
        }

        if(soulbound) {
            emit SoulboundSet(newId, soulbound);
        }

        _safeMint(to, newId);

        emit PassMinted(to, newId, expiry);

        return newId;
    }

    function isValid(uint256 tokenId) public view returns (bool) {
        if(!_exists(tokenId)) {
            return false;
        }

        uint64 exp = _expiry[tokenId];

        if(exp == 0) {
            return true;
        }

        return block.timestamp <= exp;
    }

}