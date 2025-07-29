const hre = require("hardhat");

async function main() {
  // Get the contract factory
    const LatihanVariable = await hre.ethers.getContractFactory("LatihanVariable");
    
    // Deploy the contract
    const latihan = await LatihanVariable.deploy();
    
    // Wait for deployment to finish
    await latihan.waitForDeployment();

    console.log("LatihanVariable deployed to:", await latihan.getAddress());

     // Set name
    let tx = await latihan.setName("Aldino");
    await tx.wait();

    // Get name
    const name = await latihan.getName();
    console.log("Name is:", name);
}

// Handle errors in main
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});