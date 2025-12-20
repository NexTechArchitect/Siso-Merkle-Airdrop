import { ethers } from "ethers";
import "dotenv/config";

async function main() {
  console.log("🚀 signClaim.js started");

const {
  SEPOLIA_RPC_URL,
  PRIVATE_KEY,
  AIRDROP_ADDRESS,
  USER_ADDRESS,
  TOTAL_ALLOCATION,
} = process.env;

const RPC_URL = SEPOLIA_RPC_URL;
const SIGNER_PRIVATE_KEY = PRIVATE_KEY;
const CHAIN_ID = "11155111";


  if (
    !RPC_URL ||
    !SIGNER_PRIVATE_KEY ||
    !AIRDROP_ADDRESS ||
    !USER_ADDRESS ||
    !TOTAL_ALLOCATION ||
    !CHAIN_ID
  ) {
    throw new Error("❌ Missing .env variables");
  }

  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(SIGNER_PRIVATE_KEY, provider);

  console.log("✍️ Signer address:", wallet.address);

  const domain = {
    name: "MerkleAirdrop",
    version: "1",
    chainId: BigInt(CHAIN_ID),
    verifyingContract: AIRDROP_ADDRESS,
  };

  const types = {
    Claim: [
      { name: "account", type: "address" },
      { name: "totalAllocation", type: "uint256" },
    ],
  };

  const value = {
    account: USER_ADDRESS,
    totalAllocation: BigInt(TOTAL_ALLOCATION),
  };

  const signature = await wallet.signTypedData(domain, types, value);

  const { v, r, s } = ethers.Signature.from(signature);

  console.log("\n✅ SIGNATURE GENERATED");
  console.log("signature:", signature);
  console.log("v:", v);
  console.log("r:", r);
  console.log("s:", s);
}

main().catch((e) => {
  console.error("❌ ERROR:", e);
});
