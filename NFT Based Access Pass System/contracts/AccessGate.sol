// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;
import "./IAccessPass.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract AccessGate is Ownable {
    IAccessPass public pass;
    mapping(string => uint8) public resourceTier;
    mapping(uint256 => uint8) public tokenTier;

    event ResourceTierSet(string resource, uint8 tier);
    event TokenTierSet(uint256 tokenId, uint8 tier);
    event PassUpdated(address newPass);

    constructor(address passAddress) Ownable(msg.sender) {
        require(passAddress != address(0), "INVALID PASS ADDRESS");
        pass = IAccessPass(passAddress);
    }

    function setPass(address newPass) external onlyOwner {
        require(newPass != address(0), "INVALID ADDRESS");
        pass = IAccessPass(newPass);

        emit PassUpdated(newPass);
    }

    function setResourceTier(string memory resource, uint8 tier) external onlyOwner {
        require(bytes(resource).length > 0, "RESOURCE IS NULL");

        resourceTier[resource] = tier; 
        emit ResourceTierSet(resource, tier);
    }

    function setTokenTier(uint256 tokenId, uint8 tier) external onlyOwner {
        try pass.ownerOf(tokenId) returns (address) {
            tokenTier[tokenId] = tier;
            emit TokenTierSet(tokenId, tier);
        } catch  {
            revert("NONEXISTENT TOKEN"); 
        }
    }

    function getTierInfo(uint256 tokenId, string memory resource) external view returns (uint8 userTier, uint8 requiredTier) {
        return (tokenTier[tokenId], resourceTier[resource]);
    }

    function hasAccess(address user, uint256 tokenId) public view returns (bool) {
        if (user == address(0)) return false;
        try pass.ownerOf(tokenId) returns (address owner) {
            if (owner != user) {
                return false;
            }
        } catch  {
            return false;
        }
        return pass.isValid(tokenId);
    }

    function hasAccessForResource( address user, uint256 tokenId, string memory resource ) public view returns (bool) {
        if (!hasAccess(user, tokenId)) return false;
        if (bytes(resource).length == 0) return false;

        uint8 required = resourceTier[resource];
        uint8 userTier = tokenTier[tokenId];

        return userTier >= required;
    }
}