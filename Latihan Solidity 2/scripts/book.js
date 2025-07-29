const hre = require("hardhat");

async function main() {    
    const Book = await hre.ethers.getContractFactory("Book");
    const book = await Book.deploy();
    await book.waitForDeployment();

    const bookAddress = await book.getAddress();
    console.log(`Book Telah di deploy di: ${bookAddress}`);

    // Get the signer's address
    const [signer] = await hre.ethers.getSigners();
    const signerAddress = await signer.getAddress();

    // set buku
    await book.setBook("Si Pitung", "Pitung", 1990);
    await book.setBook("Hitam Legam", "Amba", 1960);

    // get buku 
    const ambilBuku = await book.getBook(signerAddress, 0);
    console.log("Buku yang diambil:");
    console.log("Judul:", ambilBuku[0]);
    console.log("Penulis:", ambilBuku[1]);
    console.log("Tahun:", ambilBuku[2].toString());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});