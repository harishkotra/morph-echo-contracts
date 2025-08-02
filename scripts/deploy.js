const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

  const WhisperNFT = await ethers.getContractFactory("WhisperNFT");
  const whisperNFT = await WhisperNFT.deploy();

  await whisperNFT.waitForDeployment();

  console.log("WhisperNFT deployed to:", await whisperNFT.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });