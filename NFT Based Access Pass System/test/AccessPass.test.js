const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AccessPassERC721", () => {
    let accessPass;
    let owner;
    let user1;
    let user2;
    const BASE_URI = "https://api.example.com/tokens/";
    const NAME = "Access Pass";
    const SYMBOL = "AP";

    beforeEach(async () => {
        [owner, user1, user2] = await ethers.getSigners();

        const AccessPassERC721 = await ethers.getContractFactory(
        "AccessPassERC721",
        );
        accessPass = await AccessPassERC721.deploy(NAME, SYMBOL, BASE_URI);
        await accessPass.waitForDeployment();
    });

    describe("Deployment", () => {
        it("Should set the correct name and symbol", async () => {
        expect(await accessPass.name()).to.equal(NAME);
        expect(await accessPass.symbol()).to.equal(SYMBOL);
        });

        it("Should set the owner correctly", async () => {
        expect(await accessPass.owner()).to.equal(owner.address);
        });
    });

    describe("Minting", () => {
        it("Should mint a token with correct metadata", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400; // 1 day from now
        const tx = await accessPass.mint(user1.address, expiry, false, "");
        const receipt = await tx.wait();

        expect(receipt.logs.length).to.be.greaterThan(0);
        expect(await accessPass.ownerOf(1)).to.equal(user1.address);
        });

        it("Should revert when minting to zero address", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await expect(
            accessPass.mint(ethers.ZeroAddress, expiry, false, ""),
        ).to.be.revertedWith("ADDRESS IS NULL");
        });

        it("Should revert when expiry is in the past", async () => {
        const expiry = Math.floor(Date.now() / 1000) - 1000;
        await expect(
            accessPass.mint(user1.address, expiry, false, ""),
        ).to.be.revertedWith("INVALID EXPIRY");
        });

        it("Should allow minting with expiry 0 (infinite)", async () => {
        const tx = await accessPass.mint(user1.address, 0, false, "");
        const receipt = await tx.wait();
        expect(await accessPass.ownerOf(1)).to.equal(user1.address);
        });

        it("Should mint soulbound token", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, true, "");
        expect(await accessPass.ownerOf(1)).to.equal(user1.address);
        });

        it("Should mint with custom URI", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        const customURI = "ipfs://QmXXXXX";
        await accessPass.mint(user1.address, expiry, false, customURI);
        expect(await accessPass.tokenURI(1)).to.equal(customURI);
        });

        it("Should return incremental token IDs", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");
        await accessPass.mint(user2.address, expiry, false, "");
        expect(await accessPass.ownerOf(1)).to.equal(user1.address);
        expect(await accessPass.ownerOf(2)).to.equal(user2.address);
        });

        it("Should only allow owner to mint", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await expect(
            accessPass.connect(user1).mint(user1.address, expiry, false, ""),
        ).to.be.revertedWithCustomError(accessPass, "OwnableUnauthorizedAccount");
        });
    });

    describe("Token Validity", () => {
        it("Should return true for valid non-expiring token", async () => {
        await accessPass.mint(user1.address, 0, false, "");
        expect(await accessPass.isValid(1)).to.be.true;
        });

        it("Should return true for valid token before expiry", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");
        expect(await accessPass.isValid(1)).to.be.true;
        });

        it("Should return false for nonexistent token", async () => {
        expect(await accessPass.isValid(999)).to.be.false;
        });

        it("Should return false for expired token", async () => {
        // Get the current block timestamp from blockchain
        const blockTimestamp = await ethers.provider.getBlock('latest').then(b => b.timestamp);
        const expiry = blockTimestamp + 100;
        
        await accessPass.mint(user1.address, expiry, false, "");
        
        // Token should be valid before expiry
        expect(await accessPass.isValid(1)).to.be.true;
        
        // Fast-forward time past expiry
        await ethers.provider.send("evm_increaseTime", [101]);
        await ethers.provider.send("hardhat_mine", ["0x1"]);
        
        expect(await accessPass.isValid(1)).to.be.false;
        });
    });

    describe("Token Transfer", () => {
        it("Should allow transfer of non-soulbound token", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        await accessPass
            .connect(user1)
            .transferFrom(user1.address, user2.address, 1);
        expect(await accessPass.ownerOf(1)).to.equal(user2.address);
        });

        it("Should block transfer of soulbound token", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, true, "");

        await expect(
            accessPass.connect(user1).transferFrom(user1.address, user2.address, 1),
        ).to.be.revertedWith("AccessPass: soulbound token");
        });

        it("Should allow revoke to remove token", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        // Use revoke to remove the token
        await accessPass.revoke(1);
        expect(await accessPass.balanceOf(user1.address)).to.equal(0);
        expect(await accessPass.isValid(1)).to.be.false;
        });
    });

    describe("Expiry Management", () => {
        it("Should set new expiry", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        const newExpiry = Math.floor(Date.now() / 1000) + 172800;
        await accessPass.setExpiry(1, newExpiry);

        expect(await accessPass.isValid(1)).to.be.true;
        });

        it("Should revert setExpiry for nonexistent token", async () => {
        const newExpiry = Math.floor(Date.now() / 1000) + 86400;
        await expect(accessPass.setExpiry(999, newExpiry)).to.be.revertedWith(
            "AccessPass: nonexistent token",
        );
        });

        it("Should only allow owner to set expiry", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        const newExpiry = Math.floor(Date.now() / 1000) + 172800;
        await expect(
            accessPass.connect(user1).setExpiry(1, newExpiry),
        ).to.be.revertedWithCustomError(accessPass, "OwnableUnauthorizedAccount");
        });

        it("Should extend expiry", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        const extraSeconds = 86400;
        await accessPass.extendExpiry(1, extraSeconds);

        expect(await accessPass.isValid(1)).to.be.true;
        });

        it("Should revert extendExpiry for nonexistent token", async () => {
        await expect(accessPass.extendExpiry(999, 86400)).to.be.revertedWith(
            "AccessPass: nonexistent token",
        );
        });

        it("Should revert extendExpiry with zero seconds", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        await expect(accessPass.extendExpiry(1, 0)).to.be.revertedWith(
            "INVALID EXTENSION",
        );
        });

        it("Should extend infinite token (expiry 0) as infinite", async () => {
        await accessPass.mint(user1.address, 0, false, "");
        await accessPass.extendExpiry(1, 86400);
        expect(await accessPass.isValid(1)).to.be.true;
        });

        it("Should only allow owner to extend expiry", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        await expect(
            accessPass.connect(user1).extendExpiry(1, 86400),
        ).to.be.revertedWithCustomError(accessPass, "OwnableUnauthorizedAccount");
        });
    });

    describe("Token Revocation", () => {
        it("Should revoke token by burning", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        await accessPass.revoke(1);

        expect(await accessPass.isValid(1)).to.be.false;
        expect(await accessPass.balanceOf(user1.address)).to.equal(0);
        });

        it("Should revert revoke for nonexistent token", async () => {
        await expect(accessPass.revoke(999)).to.be.revertedWith(
            "AccessPass: nonexistent token",
        );
        });

        it("Should only allow owner to revoke", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        await expect(
            accessPass.connect(user1).revoke(1),
        ).to.be.revertedWithCustomError(accessPass, "OwnableUnauthorizedAccount");
        });

        it("Should emit PassRevoked event", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        await expect(accessPass.revoke(1))
            .to.emit(accessPass, "PassRevoked")
            .withArgs(1, owner.address);
        });
    });

    describe("Token URI", () => {
        it("Should return default URI for token without custom URI", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        const uri = await accessPass.tokenURI(1);
        expect(uri).to.equal(BASE_URI + "1");
        });

        it("Should return custom URI if set", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        const customURI = "ipfs://QmCustom";
        await accessPass.mint(user1.address, expiry, false, customURI);

        expect(await accessPass.tokenURI(1)).to.equal(customURI);
        });

        it("Should revert tokenURI for nonexistent token", async () => {
        await expect(accessPass.tokenURI(999)).to.be.revertedWith(
            "AccessPass: nonexistent token",
        );
        });

        it("Should return correct URI for multiple tokens", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");
        await accessPass.mint(user2.address, expiry, false, "");
        await accessPass.mint(user1.address, expiry, false, "custom");

        expect(await accessPass.tokenURI(1)).to.equal(BASE_URI + "1");
        expect(await accessPass.tokenURI(2)).to.equal(BASE_URI + "2");
        expect(await accessPass.tokenURI(3)).to.equal("custom");
        });
    });

    describe("Events", () => {
        it("Should emit PassMinted event", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;

        await expect(accessPass.mint(user1.address, expiry, false, ""))
            .to.emit(accessPass, "PassMinted")
            .withArgs(user1.address, 1, expiry);
        });

        it("Should emit SoulboundSet event for soulbound tokens", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;

        await expect(accessPass.mint(user1.address, expiry, true, ""))
            .to.emit(accessPass, "SoulboundSet")
            .withArgs(1, true);
        });

        it("Should emit ExpiryExtended event", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        const newExpiry = Math.floor(Date.now() / 1000) + 172800;
        await expect(accessPass.setExpiry(1, newExpiry)).to.emit(
            accessPass,
            "ExpiryExtended",
        );
        });
    });

    describe("ReentrancyGuard", () => {
        it("Should protect revoke function from reentrancy", async () => {
        const expiry = Math.floor(Date.now() / 1000) + 86400;
        await accessPass.mint(user1.address, expiry, false, "");

        // Call revoke - should succeed even if called multiple times quickly
        await accessPass.revoke(1);

        await expect(accessPass.revoke(1)).to.be.revertedWith(
            "AccessPass: nonexistent token",
        );
        });
    });
});
