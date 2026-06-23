const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();
    console.log("Deploying with:", deployer.address);

    const AccessGate = await hre.ethers.getContractFactory("AccessGate");
    const accessGate = await AccessGate.deploy();
    await accessGate.waitForDeployment();

    console.log("Access gate deployed to:", await accessGate.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});