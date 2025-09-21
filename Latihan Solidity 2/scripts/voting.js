const hre = require("hardhat");

async function main() {
    const Voting = await hre.ethers.getContractFactory("Voting");
    const voting = await Voting.deploy();
    await voting.waitForDeployment();

    const votingAddress = await voting.getAddress();
    console.log(`Voting di deploy di: ${votingAddress}`);

    // set candidates (hanya owner yang bisa)
    await voting.addCandidate("Aldino");
    await voting.addCandidate("Putra");
    await voting.addCandidate("Khalifah");

    const [owner, user1, user2, user3] = await hre.ethers.getSigners();

    // add voting
    await voting.connect(owner).vote(1);
    await voting.connect(user1).vote(1);
    await voting.connect(user2).vote(2);
    await voting.connect(user3).vote(3);

    // get candidate 1
    const candidate = await voting.getCandidate(1);
    console.log(`Candidate Name: ${candidate[1]}`);
    console.log(`Candidate Votes: ${candidate[2]}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
