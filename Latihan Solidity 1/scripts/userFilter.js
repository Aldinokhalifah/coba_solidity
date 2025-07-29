const hre = require("hardhat");

async function main() {
    const UserFilter = await hre.ethers.getContractFactory("UserFilter");
    const contract = await UserFilter.deploy();
    await contract.waitForDeployment();

    console.log("✅ Kontrak UserFilter dideploy di:", await contract.getAddress());

    // Tambah beberapa user (dewasa dan anak-anak)
    await contract.tambahUser("Aldino", 21);
    await contract.tambahUser("Budi", 15);
    await contract.tambahUser("Citra", 19);
    await contract.tambahUser("Dewi", 12);

    console.log("📥 Data user berhasil ditambahkan.");

    // Ambil user dewasa
    const [names, ages] = await contract.getUserDewasa();

    console.log("🧑‍💼 User Dewasa:");
    for (let i = 0; i < names.length; i++) {
        console.log(`- ${names[i]} (umur ${ages[i].toString()})`);
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
