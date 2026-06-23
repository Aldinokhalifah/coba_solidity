const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying with:", deployer.address);

    // Deploy AccessPass
    const AccessPassERC721 = await ethers.getContractFactory("AccessPassERC721");
    accessPass = await AccessPassERC721.deploy("Access Pass", "AP", "https://api.example.com/");
    await accessPass.waitForDeployment();

    const accessPassAddress = await accessPass.getAddress();

    // Deploy AccessGate
    const AccessGate = await hre.ethers.getContractFactory("AccessGate");
    const accessGate = await AccessGate.deploy(accessPass.target);

    await accessGate.waitForDeployment();

    const accessGateAddress = await accessGate.getAddress();

    console.log("Access gate deployed to:", accessGateAddress);
    console.log("Access pass deployed to:", accessPassAddress);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});