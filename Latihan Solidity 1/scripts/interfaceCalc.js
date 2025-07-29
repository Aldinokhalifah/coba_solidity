const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("🚀 Deploying contracts with:", deployer.address);

    // Deploy Calculator (implementasi)
    const Calculator = await ethers.getContractFactory("Calculator");
    const calculator = await Calculator.deploy();
    await calculator.waitForDeployment();
    console.log("✅ Calculator deployed at:", await calculator.getAddress());

    // Deploy CalculatorCaller (pemanggil interface)
    const CalculatorCaller = await ethers.getContractFactory("CalculatorCaller");
    const caller = await CalculatorCaller.deploy();
    await caller.waitForDeployment();
    console.log("✅ CalculatorCaller deployed at:", await caller.getAddress());

    // Panggil getAddition dan getSubtraction lewat interface
    const a = 10;
    const b = 10;

    const sum = await caller.getAddition(await calculator.getAddress(), a, b);
    const difference = await caller.getSubtraction(await calculator.getAddress(), a, b);
    const divide = await caller.getDivided(await calculator.getAddress(), a, b);

    console.log(`📗 ${a} + ${b} = ${sum.toString()}`);
    console.log(`📕 ${a} - ${b} = ${difference.toString()}`);
    console.log(`📙 ${a} : ${b} = ${divide.toString()}`);
}

main().catch((error) => {
    console.error("❌ ERROR:", error);
    process.exitCode = 1;
});
