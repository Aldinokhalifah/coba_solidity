const hre = require("hardhat");

async function main() {    
    const Student = await hre.ethers.getContractFactory("Student");
    const student = await Student.deploy();
    await student.waitForDeployment();

    console.log(`Student Telah di deploy di: ${await student.getAddress()}`);

    // set student 
    await student.setStudent(123456789, "Aldino", "Teknik Informatika", 2023);
    await student.setStudent(987654321, "Putra", "Sistem Informasi", 2025);

    // get student 
    const ambilStudent = await student.getStudent(987654321);
    console.log("Murid yang diambil:");
    console.log(`Nama: ${ambilStudent[0]}`);
    console.log(`Jurusan: ${ambilStudent[1]}`);
    console.log(`Tahun Masuk: ${ambilStudent[2]}`);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});