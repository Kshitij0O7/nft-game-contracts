const hre = require("hardhat");
const ethers = require("ethers");

async function main() {

  // Deploy the Alchemon contract
  const contractFactory = await hre.ethers.getContractFactory('AlchemonNft');
  const alchContract = await contractFactory.deploy();
  await alchContract.waitForDeployment();

  console.log("Contract deployed to:",await alchContract.getAddress());

  // Mint 2 genesis NFTs
  let txn;
  txn = await alchContract.mintGenesis(2, { value: ethers.parseEther('0.001') });
  await txn.wait();
  console.log("2 NFTs minted");

  // Breed genesis NFTs
  txn = await alchContract.breed(0, 1);
  await txn.wait();
  console.log("1 NFT bred");

}

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (e) {
    console.log(e);
    process.exit(1);
  }
}

runMain();