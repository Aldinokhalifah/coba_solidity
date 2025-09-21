const hre = require("hardhat");

async function main() {
    const PhoneBook = await hre.ethers.getContractFactory("PhoneBook");
    const phoneBook = await PhoneBook.deploy();
    await phoneBook.waitForDeployment();

    const phoneBookAddress = await phoneBook.getAddress();
    console.log(`Phone Book telah di deploy di: ${phoneBookAddress}`);

    const [owner, user2] = await hre.ethers.getSigners();
    const ownerAddress = await owner.getAddress();
    const user2Address = await user2.getAddress();

    // set contact by owner
    await phoneBook.connect(owner).setMyContact("Aldino", "1234567890");

    // set contact by user2
    await phoneBook.connect(user2).setMyContact("Budi", "9876543210");

    // get contact owner
    const contact1 = await phoneBook.getMyContact(ownerAddress);
    console.log(`Owner Contact -> Name: ${contact1[0]}, Phone: ${contact1[1]}`);

    // get contact user2
    const contact2 = await phoneBook.getMyContact(user2Address);
    console.log(`User2 Contact -> Name: ${contact2[0]}, Phone: ${contact2[1]}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
