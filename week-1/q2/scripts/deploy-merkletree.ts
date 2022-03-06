import { ethers } from "hardhat";

async function main() {
  const TxMerkleTree = await ethers.getContractFactory("TxMerkleTree");
  const txMerkleTree = await TxMerkleTree.deploy();

  await txMerkleTree.deployed();

  console.log("TxMerkleTree deployed to:", txMerkleTree.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
