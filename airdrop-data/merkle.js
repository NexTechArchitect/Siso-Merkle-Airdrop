import fs from "fs";
import path from "path";
import { ethers } from "ethers";
import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";

const INPUT_PATH = path.join(process.cwd(), "airdrop-data", "input.json");
const OUTPUT_PATH = path.join(process.cwd(), "airdrop-data", "output.json");

const input = JSON.parse(fs.readFileSync(INPUT_PATH, "utf8"));

const leaves = Object.entries(input).map(([address, amount]) => {
  return ethers.solidityPackedKeccak256(
    ["address", "uint256"],
    [address, ethers.parseUnits(amount, 18)]
  );
});

const tree = new MerkleTree(leaves, keccak256, {
  sortPairs: true
});

const merkleRoot = tree.getHexRoot();

const claims = {};

Object.entries(input).forEach(([address, amount]) => {
  const leaf = ethers.solidityPackedKeccak256(
    ["address", "uint256"],
    [address, ethers.parseUnits(amount, 18)]
  );

  claims[address] = {
    amount: amount,
    proof: tree.getHexProof(leaf)
  };
});

const output = {
  merkleRoot,
  claims
};

fs.writeFileSync(OUTPUT_PATH, JSON.stringify(output, null, 2));

console.log("✅ Merkle tree generated");
console.log("Merkle Root:", merkleRoot);
console.log("Output written to:", OUTPUT_PATH);
