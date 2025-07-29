const hre = require("hardhat");

async function main() {
    const UserData = await hre.ethers.getContractFactory("UserData");
    const userData = await UserData.deploy();
    await userData.waitForDeployment();

    console.log("Kontrak berhasil dideploy di:", await userData.getAddress());

    // Set data
    await userData.setUserData("Aldino", 16);

    // Get data
    const [name, age] = await userData.getUserData();
    console.log("Nama:", name);
    console.log("Usia:", age.toString());

    // Cek apakah dewasa
    const isDewasa = await userData.isAdult(21);
    console.log("Apakah Dewasa?:", isDewasa);

    // Cek nama cocok
    const cocok = await userData.cekNama("Aldino");
    console.log("Apakah nama cocok?:", cocok);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
