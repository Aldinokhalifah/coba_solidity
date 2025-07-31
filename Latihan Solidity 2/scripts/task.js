const hre = require("hardhat");

async function main() {
    const Task = await hre.ethers.getContractFactory("Task");
    const task = await Task.deploy();
    await task.waitForDeployment();

    console.log(`Task berhasil dideploy di: ${await task.getAddress()}`);

    // get owner
    const [signer] = await hre.ethers.getSigners();
    const signerAddress = await signer.getAddress();

    // set tugas
    await task.setTask(signerAddress, "Latihan Solidity 1", false);
    await task.setTask(signerAddress, "Latihan Solidity 2", true);
    await task.setTask(signerAddress, "Latihan Solidity 3", true);

    // set tugas selesai
    await task.setDoneTask(0, true);

    // get tugas
    const ambilTugas = await task.getTask(signerAddress);
    console.log("Tugas yang ada: ");
    for(let i = 0; i < ambilTugas[0].length; i++) {
        console.log(`Tugas ${i + 1}:`);
        console.log(`Deskripsi: ${ambilTugas[0][i]}`);
        console.log(`Selesai: ${ambilTugas[1][i]}`);
        console.log("-------------------");
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});