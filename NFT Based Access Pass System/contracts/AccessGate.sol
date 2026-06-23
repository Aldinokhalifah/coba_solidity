// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;
import "./IAccessPass.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract AccessGate is Ownable {
    mapping(string => uint8) public resourceTier;
    // passAddress => tokenId => tier  (nested, supaya gak collide antar collection)
    mapping(address => mapping(uint256 => uint8)) public tokenTier;

    event ResourceTierSet(string resource, uint8 tier);
    event TokenTierSet(address indexed passAddress, uint256 indexed tokenId, uint8 tier);

    constructor() Ownable(msg.sender) {}

    function setResourceTier(string memory resource, uint8 tier) external onlyOwner {
        require(bytes(resource).length > 0, "RESOURCE IS NULL");
        resourceTier[resource] = tier;
        emit ResourceTierSet(resource, tier);
    }

    function setTokenTier(address passAddress, uint256 tokenId, uint8 tier) external onlyOwner {
        require(passAddress != address(0), "INVALID PASS ADDRESS");
        try IAccessPass(passAddress).ownerOf(tokenId) returns (address) {
            tokenTier[passAddress][tokenId] = tier;
            emit TokenTierSet(passAddress, tokenId, tier);
        } catch {
            revert("NONEXISTENT TOKEN");
        }
    }

    function getTierInfo(address passAddress, uint256 tokenId, string memory resource)
        external view returns (uint8 userTier, uint8 requiredTier)
    {
        return (tokenTier[passAddress][tokenId], resourceTier[resource]);
    }

    function hasAccess(address passAddress, address user, uint256 tokenId) public view returns (bool) {
        if (passAddress == address(0) || user == address(0)) return false;

        IAccessPass pass = IAccessPass(passAddress);

        try pass.ownerOf(tokenId) returns (address owner) {
            if (owner != user) return false;
        } catch {
            return false;
        }

        return pass.isValid(tokenId);
    }

    function hasAccessForResource(address passAddress, address user, uint256 tokenId, string memory resource) public view returns (bool) {
        if (!hasAccess(passAddress, user, tokenId)) return false;
        if (bytes(resource).length == 0) return false;

        uint8 required = resourceTier[resource];
        uint8 userTier = tokenTier[passAddress][tokenId];

        return userTier >= required;
    }
}