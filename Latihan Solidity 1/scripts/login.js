const hre = require("hardhat");

async function main() {
    const LoginSederhana = await hre.ethers.getContractFactory("LoginSederhana");
    const loginContract  = await LoginSederhana.deploy();
    await loginContract.waitForDeployment();

    console.log("Kontrak LoginSederhana dideploy di:", await loginContract.getAddress());

    // Set username dan password
    const set = await loginContract.setAkun("Aldino", "123456");
    await set.wait();

    // coba login dengan data yang benar
    const loginSucess = await loginContract.login("Aldino", "123456");
    console.log("Login Berhasil: ", loginSucess);

      // Coba login dengan data yang salah
    const loginGagal = await loginContract.login("aldo", "salahpass");
    console.log("Login gagal?", loginGagal);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});