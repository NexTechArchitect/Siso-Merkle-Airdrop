import { ethers } from "ethers";
import "dotenv/config";

async function main() {
  const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
  const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  const domain = {
    name: "MerkleAirdrop",
    version: "1",
    chainId: Number(process.env.CHAIN_ID),
    verifyingContract: process.env.AIRDROP_ADDRESS,
  };

  const types = {
    Claim: [
      { name: "account", type: "address" },
      { name: "totalAllocation", type: "uint256" },
    ],
  };

  const value = {
    account: process.env.CLAIM_USER,
    totalAllocation: process.env.TOTAL_ALLOCATION,
  };

  const signature = await signer.signTypedData(domain, types, value);

  console.log("\n=== SIGNATURE GENERATED ===");
  console.log("User:", value.account);
  console.log("Allocation (wei):", value.totalAllocation);
  console.log("Signature:", signature);
}

main().catch(console.error);
