const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AccessGate", () => {
    let accessGate;
    let accessPass;
    let owner;
    let user1;
    let user2;
    let user3;

    beforeEach(async () => {
        [owner, user1, user2, user3] = await ethers.getSigners();

        // Deploy AccessPassERC721
        const AccessPassERC721 = await ethers.getContractFactory("AccessPassERC721");
        accessPass = await AccessPassERC721.deploy("Access Pass", "AP", "https://api.example.com/");
        await accessPass.waitForDeployment();

        // Deploy AccessGate
        const AccessGate = await ethers.getContractFactory("AccessGate");
        accessGate = await AccessGate.deploy(accessPass.target);
        await accessGate.waitForDeployment();
    });

    describe("Deployment", () => {
        it("Should set the correct pass address", async () => {
        expect(await accessGate.pass()).to.equal(accessPass.target);
        });

        it("Should set the owner correctly", async () => {
        expect(await accessGate.owner()).to.equal(owner.address);
        });

        it("Should revert when deploying with zero address", async () => {
        const AccessGate = await ethers.getContractFactory("AccessGate");
        await expect(
            AccessGate.deploy(ethers.ZeroAddress)
        ).to.be.revertedWith("INVALID PASS ADDRESS");
        });
    });

    describe("Pass Management", () => {
        it("Should update pass address", async () => {
        // Deploy a second pass contract
        const AccessPassERC721 = await ethers.getContractFactory("AccessPassERC721");
        const newPass = await AccessPassERC721.deploy("New Pass", "NP", "https://new.example.com/");
        await newPass.waitForDeployment();

        await accessGate.setPass(newPass.target);
        expect(await accessGate.pass()).to.equal(newPass.target);
        });

        it("Should revert when setting zero address as pass", async () => {
        await expect(
            accessGate.setPass(ethers.ZeroAddress)
        ).to.be.revertedWith("INVALID ADDRESS");
        });

        it("Should only allow owner to set pass", async () => {
        const AccessPassERC721 = await ethers.getContractFactory("AccessPassERC721");
        const newPass = await AccessPassERC721.deploy("New Pass", "NP", "https://new.example.com/");
        await newPass.waitForDeployment();

        await expect(
            accessGate.connect(user1).setPass(newPass.target)
        ).to.be.revertedWithCustomError(accessGate, "OwnableUnauthorizedAccount");
        });

        it("Should emit PassUpdated event", async () => {
        const AccessPassERC721 = await ethers.getContractFactory("AccessPassERC721");
        const newPass = await AccessPassERC721.deploy("New Pass", "NP", "https://new.example.com/");
        await newPass.waitForDeployment();

        await expect(accessGate.setPass(newPass.target))
            .to.emit(accessGate, "PassUpdated")
            .withArgs(newPass.target);
        });
    });

    describe("Resource Tier Management", () => {
        it("Should set resource tier", async () => {
        const resource = "premium_feature";
        const tier = 2;

        await accessGate.setResourceTier(resource, tier);
        expect(await accessGate.resourceTier(resource)).to.equal(tier);
        });

        it("Should update resource tier", async () => {
        const resource = "premium_feature";
        await accessGate.setResourceTier(resource, 2);
        await accessGate.setResourceTier(resource, 3);
        expect(await accessGate.resourceTier(resource)).to.equal(3);
        });

        it("Should revert when resource is empty string", async () => {
        await expect(
            accessGate.setResourceTier("", 1)
        ).to.be.revertedWith("RESOURCE IS NULL");
        });

        it("Should only allow owner to set resource tier", async () => {
        await expect(
            accessGate.connect(user1).setResourceTier("premium_feature", 2)
        ).to.be.revertedWithCustomError(accessGate, "OwnableUnauthorizedAccount");
        });

        it("Should allow setting tier to 0", async () => {
        await accessGate.setResourceTier("public_resource", 0);
        expect(await accessGate.resourceTier("public_resource")).to.equal(0);
        });

        it("Should emit ResourceTierSet event", async () => {
        await expect(accessGate.setResourceTier("premium_feature", 2))
            .to.emit(accessGate, "ResourceTierSet")
            .withArgs("premium_feature", 2);
        });

        it("Should handle multiple resources", async () => {
        await accessGate.setResourceTier("resource1", 1);
        await accessGate.setResourceTier("resource2", 2);
        await accessGate.setResourceTier("resource3", 3);

        expect(await accessGate.resourceTier("resource1")).to.equal(1);
        expect(await accessGate.resourceTier("resource2")).to.equal(2);
        expect(await accessGate.resourceTier("resource3")).to.equal(3);
        });
    });

    describe("Token Tier Management", () => {
        beforeEach(async () => {
        // Mint a token for user1
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");
        });

        it("Should set token tier", async () => {
        const tokenId = 1;
        const tier = 2;

        await accessGate.setTokenTier(tokenId, tier);
        expect(await accessGate.tokenTier(tokenId)).to.equal(tier);
        });

        it("Should update token tier", async () => {
        const tokenId = 1;
        await accessGate.setTokenTier(tokenId, 2);
        await accessGate.setTokenTier(tokenId, 3);
        expect(await accessGate.tokenTier(tokenId)).to.equal(3);
        });

        it("Should revert when setting tier for nonexistent token", async () => {
        await expect(
            accessGate.setTokenTier(999, 2)
        ).to.be.revertedWith("NONEXISTENT TOKEN");
        });

        it("Should only allow owner to set token tier", async () => {
        await expect(
            accessGate.connect(user1).setTokenTier(1, 2)
        ).to.be.revertedWithCustomError(accessGate, "OwnableUnauthorizedAccount");
        });

        it("Should emit TokenTierSet event", async () => {
        await expect(accessGate.setTokenTier(1, 2))
            .to.emit(accessGate, "TokenTierSet")
            .withArgs(1, 2);
        });

        it("Should allow setting tier to 0", async () => {
        await accessGate.setTokenTier(1, 0);
        expect(await accessGate.tokenTier(1)).to.equal(0);
        });

        it("Should handle multiple token tiers", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user2.address, expiry, false, "");
        await accessPass.mint(user3.address, expiry, false, "");

        await accessGate.setTokenTier(1, 1);
        await accessGate.setTokenTier(2, 2);
        await accessGate.setTokenTier(3, 3);

        expect(await accessGate.tokenTier(1)).to.equal(1);
        expect(await accessGate.tokenTier(2)).to.equal(2);
        expect(await accessGate.tokenTier(3)).to.equal(3);
        });
    });

    describe("Tier Information", () => {
        beforeEach(async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");
        await accessGate.setTokenTier(1, 3);
        await accessGate.setResourceTier("premium_feature", 2);
        });

        it("Should return correct tier information", async () => {
        const [userTier, requiredTier] = await accessGate.getTierInfo(1, "premium_feature");
        expect(userTier).to.equal(3);
        expect(requiredTier).to.equal(2);
        });

        it("Should return 0 for nonexistent token tier", async () => {
        const [userTier, requiredTier] = await accessGate.getTierInfo(999, "premium_feature");
        expect(userTier).to.equal(0);
        expect(requiredTier).to.equal(2);
        });

        it("Should return 0 for nonexistent resource tier", async () => {
        const [userTier, requiredTier] = await accessGate.getTierInfo(1, "nonexistent_resource");
        expect(userTier).to.equal(3);
        expect(requiredTier).to.equal(0);
        });

        it("Should handle empty resource string", async () => {
        const [userTier, requiredTier] = await accessGate.getTierInfo(1, "");
        expect(userTier).to.equal(3);
        expect(requiredTier).to.equal(0);
        });
    });

    describe("Basic Access Control", () => {
        beforeEach(async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");
        await accessPass.mint(user2.address, expiry, false, "");
        });

        it("Should allow access for token owner with valid token", async () => {
        expect(await accessGate.hasAccess(user1.address, 1)).to.be.true;
        });

        it("Should deny access for zero address", async () => {
        expect(await accessGate.hasAccess(ethers.ZeroAddress, 1)).to.be.false;
        });

        it("Should deny access for non-owner", async () => {
        expect(await accessGate.hasAccess(user2.address, 1)).to.be.false;
        });

        it("Should deny access for nonexistent token", async () => {
        expect(await accessGate.hasAccess(user1.address, 999)).to.be.false;
        });

        it("Should deny access for invalid token", async () => {
        // Mint an expired token
        const expiry = Math.floor(Date.now() / 1000) - 1000;
        // This should fail during mint, so we'll revoke instead
        await accessPass.revoke(1);
        expect(await accessGate.hasAccess(user1.address, 1)).to.be.false;
        });

        it("Should emit correct results for multiple users", async () => {
        expect(await accessGate.hasAccess(user1.address, 1)).to.be.true;
        expect(await accessGate.hasAccess(user1.address, 2)).to.be.false;
        expect(await accessGate.hasAccess(user2.address, 1)).to.be.false;
        expect(await accessGate.hasAccess(user2.address, 2)).to.be.true;
        });
    });

    describe("Resource Access Control", () => {
        beforeEach(async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");
        await accessPass.mint(user2.address, expiry, false, "");

        // Set up tier requirements
        await accessGate.setTokenTier(1, 3);
        await accessGate.setTokenTier(2, 1);
        await accessGate.setResourceTier("premium_feature", 2);
        await accessGate.setResourceTier("basic_feature", 1);
        });

        it("Should grant access when user tier >= required tier", async () => {
        expect(await accessGate.hasAccessForResource(user1.address, 1, "premium_feature")).to.be.true;
        expect(await accessGate.hasAccessForResource(user1.address, 1, "basic_feature")).to.be.true;
        });

        it("Should deny access when user tier < required tier", async () => {
        expect(await accessGate.hasAccessForResource(user2.address, 2, "premium_feature")).to.be.false;
        });

        it("Should grant access when tiers are equal", async () => {
        expect(await accessGate.hasAccessForResource(user2.address, 2, "basic_feature")).to.be.true;
        });

        it("Should deny access for nonexistent token", async () => {
        expect(await accessGate.hasAccessForResource(user1.address, 999, "premium_feature")).to.be.false;
        });

        it("Should deny access for empty resource string", async () => {
        expect(await accessGate.hasAccessForResource(user1.address, 1, "")).to.be.false;
        });

        it("Should deny access if basic hasAccess returns false", async () => {
        expect(await accessGate.hasAccessForResource(user2.address, 1, "basic_feature")).to.be.false;
        });

        it("Should deny access for revoked token", async () => {
        await accessPass.revoke(1);
        expect(await accessGate.hasAccessForResource(user1.address, 1, "premium_feature")).to.be.false;
        });

        it("Should handle multiple resources correctly", async () => {
        await accessGate.setResourceTier("vip_feature", 3);
        
        expect(await accessGate.hasAccessForResource(user1.address, 1, "vip_feature")).to.be.true;
        expect(await accessGate.hasAccessForResource(user2.address, 2, "vip_feature")).to.be.false;
        });

        it("Should deny access for non-owner of token", async () => {
        expect(await accessGate.hasAccessForResource(user2.address, 1, "premium_feature")).to.be.false;
        expect(await accessGate.hasAccessForResource(user1.address, 2, "basic_feature")).to.be.false;
        });
    });

    describe("Integration Tests", () => {
        it("Should handle complete access flow", async () => {
        // 1. Mint token
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        // 2. Set tiers
        await accessGate.setTokenTier(1, 3);
        await accessGate.setResourceTier("premium_feature", 2);
        await accessGate.setResourceTier("vip_feature", 4);

        // 3. Check access
        expect(await accessGate.hasAccessForResource(user1.address, 1, "premium_feature")).to.be.true;
        expect(await accessGate.hasAccessForResource(user1.address, 1, "vip_feature")).to.be.false;

        // 4. Upgrade user tier
        await accessGate.setTokenTier(1, 4);
        expect(await accessGate.hasAccessForResource(user1.address, 1, "vip_feature")).to.be.true;

        // 5. Revoke token
        await accessPass.revoke(1);
        expect(await accessGate.hasAccessForResource(user1.address, 1, "premium_feature")).to.be.false;
        });

        it("Should handle multiple users with different tiers", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");
        await accessPass.mint(user2.address, expiry, false, "");
        await accessPass.mint(user3.address, expiry, false, "");

        // Setup tiers
        await accessGate.setTokenTier(1, 3);
        await accessGate.setTokenTier(2, 2);
        await accessGate.setTokenTier(3, 1);

        await accessGate.setResourceTier("resource_level_2", 2);

        // Verify access
        expect(await accessGate.hasAccessForResource(user1.address, 1, "resource_level_2")).to.be.true;
        expect(await accessGate.hasAccessForResource(user2.address, 2, "resource_level_2")).to.be.true;
        expect(await accessGate.hasAccessForResource(user3.address, 3, "resource_level_2")).to.be.false;
        });

        it("Should handle changing pass contract", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        // Initial setup
        await accessGate.setTokenTier(1, 2);
        expect(await accessGate.hasAccess(user1.address, 1)).to.be.true;

        // Deploy new pass contract
        const AccessPassERC721 = await ethers.getContractFactory("AccessPassERC721");
        const newPass = await AccessPassERC721.deploy("New Pass", "NP", "https://new.example.com/");
        await newPass.waitForDeployment();

        // Change gate to use new pass
        await accessGate.setPass(newPass.target);
        expect(await accessGate.pass()).to.equal(newPass.target);

        // User should no longer have access in new pass (no tokens minted there)
        expect(await accessGate.hasAccess(user1.address, 1)).to.be.false;

        // Mint in new pass
        await newPass.mint(user1.address, expiry, false, "");
        await accessGate.setTokenTier(1, 2);

        // Now access should work again
        expect(await accessGate.hasAccess(user1.address, 1)).to.be.true;
        });
    });

    describe("Edge Cases", () => {
        it("Should handle very high tier numbers", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        const highTier = 255; // max uint8
        await accessGate.setTokenTier(1, highTier);
        await accessGate.setResourceTier("resource", highTier);

        expect(await accessGate.hasAccessForResource(user1.address, 1, "resource")).to.be.true;
        });

        it("Should handle very long resource names", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        const longResource = "a".repeat(1000);
        await accessGate.setTokenTier(1, 1);
        await accessGate.setResourceTier(longResource, 1);

        expect(await accessGate.hasAccessForResource(user1.address, 1, longResource)).to.be.true;
        });

        it("Should preserve tier settings across multiple operations", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        await accessGate.setTokenTier(1, 3);
        await accessGate.setResourceTier("resource", 2);

        // Do other operations
        await accessPass.mint(user2.address, expiry, false, "");
        await accessGate.setTokenTier(2, 1);

        // Original settings should be preserved
        expect(await accessGate.tokenTier(1)).to.equal(3);
        expect(await accessGate.resourceTier("resource")).to.equal(2);
        });
    });
});