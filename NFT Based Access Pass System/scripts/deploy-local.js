const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying with:", deployer.address);

    // Deploy PassFactory
    const Factory = await hre.ethers.getContractFactory("PassFactory");
    const factory = await Factory.deploy();

    await factory.waitForDeployment();

    const factoryAddress = await factory.getAddress();

    console.log("PassFactory deployed to:", factoryAddress);

    // Optional: langsung create pass
    const tx = await factory.createPass(
        "Access Pass",
        "APASS",
        "https://example.com/metadata/"
    );

    const receipt = await tx.wait();

    console.log("Pass created. Tx hash:", receipt.hash);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});