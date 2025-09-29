const hre = require("hardhat");

async function main() {
    const LoyaltyPoints = await hre.ethers.getContractFactory("LoyaltyPoints");
    const loyaltyPoints = await LoyaltyPoints.deploy();
    loyaltyPoints.waitForDeployment();

    const loyaltyPointsAddress = await loyaltyPoints.getAddress();
    console.log(`Loyalty Points telah di deploy di: ${loyaltyPointsAddress}`);

    // Get the owner's address
    const [owner1, owner2] = await hre.ethers.getSigners();
    const owner1Address = await owner1.getAddress();
    const owner2Address = await owner2.getAddress();

    // Add Points
    await loyaltyPoints.addPoints(owner1Address, 67);
    await loyaltyPoints.addPoints(owner2Address, 304);

    // Redeem Points
    await loyaltyPoints.redeemPoints(owner1Address, 10);
    await loyaltyPoints.redeemPoints(owner2Address, 200);

    // Get Points
    await loyaltyPoints.getPoints(owner1Address);
    await loyaltyPoints.getPoints(owner2Address);

    const [tier1, points1] = await loyaltyPoints.getPoints(owner1Address);
    console.log(`Owner1 -> Tier: ${tier1}, Points: ${points1}`);

    const [tier2, points2] = await loyaltyPoints.getPoints(owner2Address);
    console.log(`Owner2 -> Tier: ${tier2}, Points: ${points2}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});