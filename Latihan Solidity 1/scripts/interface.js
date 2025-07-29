const hre = require("hardhat");

async function main() {
    const interface = await hre.ethers.getContractFactory("LatihanInterface");
    const contract = await interface.deploy();
    await contract.waitForDeployment();

    console.log("✅ Kontrak LatihanInterface dideploy di:", await contract.getAddress());

    // Kirim Token
    await contract.sendToken(0x5FbDB2315678afecb367f032d93F642f64180aa3, 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512, 2);

    console.log("Token Berhasil Dikirim.");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
