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

    constructor(string memory name_, string memory symbol_, string memory baseURI_)
        ERC721(name_, symbol_)
        Ownable(msg.sender)
    {
        _baseTokenURI = baseURI_;
    }

    function _tokenExists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    modifier onlyExisting(uint256 tokenId) {
        require(_tokenExists(tokenId), "AccessPass: nonexistent token");
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
        if(!_tokenExists(tokenId)) {
            return false;
        }

        uint64 exp = _expiry[tokenId];

        if(exp == 0) {
            return true;
        }

        return block.timestamp <= exp;
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);

        // block normal transfers only
        if (from != address(0) && to != address(0)) {
            require(!_soulbound[tokenId], "AccessPass: soulbound token");
        }

        return super._update(to, tokenId, auth);
    }

    function revoke(uint256 tokenId) external onlyOwner onlyExisting(tokenId) nonReentrant {
        address operator = _msgSender();  

        delete _expiry[tokenId];
        delete _soulbound[tokenId];
        delete _tokenURIs[tokenId];

        // Token is revoked by burning it
        _burn(tokenId);
        emit PassRevoked(tokenId, operator);
    }

    function setExpiry(uint256 tokenId, uint64 newExpiry) external onlyOwner onlyExisting(tokenId) {
        uint64 old = _expiry[tokenId];
        _expiry[tokenId] = newExpiry;

        emit ExpiryExtended(tokenId, old, newExpiry);
    }

    function extendExpiry(uint256 tokenId, uint64 extraSeconds) external onlyOwner onlyExisting(tokenId) {
        require(extraSeconds > 0, "INVALID EXTENSION");

        uint64 old = _expiry[tokenId];
        uint64 newExpiry;

        if(old == 0) {
            // infinite
            newExpiry = 0;
        } else {
            newExpiry = old + extraSeconds;
        }

        _expiry[tokenId] = newExpiry;

        emit ExpiryExtended(tokenId, old, newExpiry);
    }

    function tokenURI(uint256 tokenId) public view override onlyExisting(tokenId) returns (string memory) {
        string memory customURI = _tokenURIs[tokenId];

        if (bytes(customURI).length > 0) {
            return customURI;
        }

        return string(abi.encodePacked(_baseTokenURI, _toString(tokenId)));
    }
}