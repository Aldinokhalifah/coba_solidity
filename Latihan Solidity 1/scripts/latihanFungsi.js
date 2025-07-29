const hre = require("hardhat");

async function main() {
  // Get the contract factory
    const LatihanFungsi = await hre.ethers.getContractFactory("LatihanFungsi");
    
    // Deploy the contract
    const latihan = await LatihanFungsi.deploy();
    
    // Wait for deployment to finish
    await latihan.waitForDeployment();

    console.log("LatihanFungsi deployed to:", await latihan.getAddress());

     // Set greet
    let tx = await latihan.setGreeting("Hello Aldino");
    await tx.wait();

    // Get greet
    const greet = await latihan.getGreeting();
    console.log(greet);
}

// Handle errors in main
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});