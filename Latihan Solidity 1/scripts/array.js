const hre = require("hardhat");

async function main() {
    const DataArray = await hre.ethers.getContractFactory("DataArray");
    const dataArray = await DataArray.deploy();
    await dataArray.waitForDeployment();

    console.log("Kontrak DataArray berhasil dideploy di:", await dataArray.getAddress());

    // Tambahkan nama
    await dataArray.tambahNama("Aldino");
    await dataArray.tambahNama("Budi");
    await dataArray.tambahNama("Citra");

    // Ambil jumlah nama
    const jumlah = await dataArray.getJumlahNama();
    console.log("Jumlah nama yang disimpan:", jumlah.toString());

    // Ambil nama berdasarkan index
    const namaKe1 = await dataArray.getIndexNama(0);
    const namaKe2 = await dataArray.getIndexNama(1);
    console.log("Nama index 0:", namaKe1);
    console.log("Nama index 1:", namaKe2);

    // Ambil semua nama
    const semuaNama = await dataArray.getSemuaNama();
    console.log("Semua nama:", semuaNama);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});