const hre = require("hardhat");

async function main() {
    const LatihanArray = await hre.ethers.getContractFactory("LatihanArray");
    const arrayContract = await LatihanArray.deploy();
    await arrayContract.waitForDeployment();

    console.log("✅ Kontrak LatihanArray dideploy di:", await arrayContract.getAddress());

    // Tambahkan angka ke array
    await arrayContract.tambahAngka(10);
    await arrayContract.tambahAngka(20);
    await arrayContract.tambahAngka(30);

    console.log("📥 Tambah angka selesai.");

    // Tampilkan semua angka
    const angka1 = await arrayContract.getAngka(0);
    const angka2 = await arrayContract.getAngka(1);
    const angka3 = await arrayContract.getAngka(2);
    console.log("📊 Isi array:", angka1.toString(), angka2.toString(), angka3.toString());

    // Jumlahkan semua angka
    const total = await arrayContract.jumlahSemua();
    console.log("➕ Total semua angka:", total.toString());

    // Cari angka
    const cek20 = await arrayContract.cariAngka(20);
    const cek99 = await arrayContract.cariAngka(99);
    console.log("🔍 Angka 20 ditemukan?", cek20);
    console.log("🔍 Angka 99 ditemukan?", cek99);

    // Hapus angka terakhir
    await arrayContract.hapusAngkaTerakhir();
    console.log("❌ Hapus angka terakhir selesai.");

    // Jumlah setelah dihapus
    const totalBaru = await arrayContract.jumlahSemua();
    console.log("➕ Total baru setelah hapus:", totalBaru.toString());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
