const hre = require('hardhat');

async function main() {
    const RentalBook = await hre.ethers.getContractFactory('RentalBook');
    const rentalBook = await RentalBook.deploy();
    await rentalBook.waitForDeployment();

    const rentalBookAddress = await rentalBook.getAddress();
    console.log(`Rental Book di deploy di: ${rentalBookAddress}`);

    // get signers
    const [owner, user] = await hre.ethers.getSigners();
    const ownerAddress = await owner.getAddress();
    const userAddress = await user.getAddress();

    // add books - gunakan owner signer, bukan address
    await rentalBook.connect(owner).addBook("Si Gundul");
    console.log(`Owner dengan address: ${ownerAddress} menambahkan buku: Si Gundul`);
    await rentalBook.connect(owner).addBook("Si Gondrong");
    console.log(`Owner dengan address: ${ownerAddress} menambahkan buku: Si Gondrong`);
    await rentalBook.connect(owner).addBook("Si Pendek");
    console.log(`Owner dengan address: ${ownerAddress} menambahkan buku: Si Pendek`);
    await rentalBook.connect(owner).addBook("Si Tinggi");
    console.log(`Owner dengan address: ${ownerAddress} menambahkan buku: Si Tinggi`);

    // borrow book - gunakan user signer, bukan address
    await rentalBook.connect(user).borrowBook(1);
    console.log(`User dengan address: ${userAddress} meminjam buku dengan ID: 1`);
    await rentalBook.connect(user).borrowBook(3);
    console.log(`User dengan address: ${userAddress} meminjam buku dengan ID: 3`);

    // Optional: Get borrowed books to verify
    const [ids, titles] = await rentalBook.getBorrowedBooks(userAddress);
    console.log("\nDaftar buku yang dipinjam:");
    for(let i = 0; i < ids.length; i++) {
        console.log(`ID: ${ids[i]}, Judul: ${titles[i]}`);
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});