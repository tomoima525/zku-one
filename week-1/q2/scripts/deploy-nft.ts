import { ethers } from "hardhat";
import { MintNFT } from "typechain";

// MerkleTree Contract should be deployed in advance in order to set MerkleTree address
async function main() {
  const MintNFT = await ethers.getContractFactory("MintNFT");
  const mintNFT = (await MintNFT.deploy()) as MintNFT;

  await mintNFT.deployed();
  // set MerkleTree
  await mintNFT.setMerkleTree("0xaaaaa");

  console.log("MintNFT deployed to:", mintNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
