const hre = require("hardhat");

async function main() {
    const UserList = await hre.ethers.getContractFactory("UserList");
    const userList = await UserList.deploy();
    await userList.waitForDeployment();

    console.log("✅ Kontrak UserList dideploy di:", await userList.getAddress());

    // Tambah beberapa user
    await userList.tambahUser("Aldino", 21);
    await userList.tambahUser("Fajar", 19);
    await userList.tambahUser("Sarah", 25);

    console.log("📥 User berhasil ditambahkan");

    // Cek jumlah user
    const jumlah = await userList.getJumlahUser();
    console.log("📊 Jumlah user:", jumlah.toString());

    // Ambil user pertama
    const user0 = await userList.getUser(0);
    console.log(`👤 User ke-0: Nama = ${user0[0]}, Umur = ${user0[1].toString()}`);

    // Ambil user kedua
    const user1 = await userList.getUser(1);
    console.log(`👤 User ke-1: Nama = ${user1[0]}, Umur = ${user1[1].toString()}`);

    // Hapus user terakhir
    await userList.hapusUserTerkini();
    console.log("❌ User terakhir dihapus");

    // Jumlah user setelah penghapusan
    const jumlahBaru = await userList.getJumlahUser();
    console.log("📊 Jumlah user terbaru:", jumlahBaru.toString());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
