
<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=600&size=28&pause=1000&color=00FF99&center=true&vCenter=true&width=1000&height=100&lines=SISO+MERKLE+AIRDROP;Gas-Optimized+Distribution+System;EIP-712+Signatures+%7C+Phased+Vesting;Cryptographically+Secure+Claims" alt="Typing Effect" />

  <br/>

  <p>
    <a href="https://github.com/NexTechArchitect/Siso-Merkle-Airdrop">
      <img src="https://img.shields.io/badge/Standard-ERC20-363636?style=for-the-badge&logo=ethereum&logoColor=white" />
    </a>
    <img src="https://img.shields.io/badge/Security-EIP--712_Typed-6A0DAD?style=for-the-badge&logo=opensea&logoColor=white" />
    <img src="https://img.shields.io/badge/Logic-Merkle_Proofs-007AFF?style=for-the-badge&logo=json&logoColor=white" />
    <img src="https://img.shields.io/badge/Tech-Foundry_%26_Node-BE5212?style=for-the-badge&logo=foundry&logoColor=white" />
  </p>

  <p width="80%">
    <b>A production-grade token distribution architecture.</b><br/>
    Eliminates gas costs for issuers by off-loading eligibility computation, secured by cryptographic proofs and typed data signatures.
  </p>

  <br/>

  <table>
    <tr>
      <td align="center"><a href="#-system-architecture"><strong>🏗 Architecture</strong></a></td>
      <td align="center"><a href="#-vesting--mechanics"><strong>⏳ Vesting Logic</strong></a></td>
      <td align="center"><a href="#-security-model"><strong>🔐 Security</strong></a></td>
      <td align="center"><a href="#-setup--deployment"><strong>🚀 Quick Start</strong></a></td>
    </tr>
  </table>

</div>

---

<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=600&size=28&pause=1000&color=00FF99&center=true&vCenter=true&width=1000&height=100&lines=SISO+MERKLE+AIRDROP;Production-Grade+Distribution;EIP-712+Signatures+%7C+Phased+Vesting;Gas-Optimized+Architecture" alt="Typing Effect" />

  <br/>

  <p>
    <a href="https://github.com/NexTechArchitect/Siso-Merkle-Airdrop">
      <img src="https://img.shields.io/badge/Standard-ERC20-363636?style=for-the-badge&logo=ethereum&logoColor=white" />
    </a>
    <img src="https://img.shields.io/badge/Security-EIP--712_Typed-6A0DAD?style=for-the-badge&logo=opensea&logoColor=white" />
    <img src="https://img.shields.io/badge/Logic-Merkle_Proofs-007AFF?style=for-the-badge&logo=json&logoColor=white" />
    <img src="https://img.shields.io/badge/Tech-Foundry-BE5212?style=for-the-badge&logo=foundry&logoColor=white" />
  </p>

  <p width="80%">
    <b>A production-grade architecture for distributing tokens efficiently.</b><br/>
    Secured by Merkle Proofs and EIP-712 Signatures to minimize on-chain costs.
  </p>

  <br/>

  <table>
    <tr>
      <td align="center"><a href="#-architectural-flow"><strong>🏗 Architecture</strong></a></td>
      <td align="center"><a href="#-vesting-schedule"><strong>⏳ Vesting</strong></a></td>
      <td align="center"><a href="#-security-mechanics"><strong>🔐 Security</strong></a></td>
      <td align="center"><a href="#-project-structure"><strong>📂 Structure</strong></a></td>
    </tr>
  </table>

</div>

---

## 🏗 Architectural Flow

The system splits logic between **Off-Chain Computation** (saving gas) and **On-Chain Verification** (security).

```mermaid
graph LR
    subgraph OFF [💻 Off-Chain Backend]
      Input[("📄 Input List")] -->|Hash| Gen{Merkle Script}
      Gen -->|Generate| Root[Merkle Root]
      Gen -->|Generate| Proofs[JSON Proofs]
    end

    subgraph ON [⛓️ On-Chain Contract]
      Root -.->|1. Deploy Root| Contract[Airdrop Contract]
      User((👤 User)) -->|2. Sign Request| Wallet[MetaMask]
      Wallet -->|3. Submit Proof| Contract
      Contract -->|4. Verify & Transfer| User
    end

    style OFF fill:#1a1a1a,stroke:#666,stroke-width:1px,color:#fff
    style ON fill:#0d1117,stroke:#00FF99,stroke-width:2px,color:#fff
    style Contract fill:#222,stroke:#007AFF,stroke-width:2px
    style Gen fill:#333,stroke:#FF9900,stroke-width:2px
### 🧠 How It Works (Step-by-Step)

| Step | Component | Action & Description |
| --- | --- | --- |
| **1.** | **Hashing** | We take thousands of addresses (`input.json`), hash them, and organize them into a **Merkle Tree**. |
| **2.** | **Deployment** | Instead of uploading 10,000 addresses to Ethereum (which costs thousands of dollars), we upload **only the Root Hash (32 bytes)**. |
| **3.** | **Signing** | The user connects via Frontend. They sign a typed message (EIP-712). This proves they are the real owner of the address. |
| **4.** | **Verification** | The Smart Contract checks: <br>

<br> 1. Does the signature match the sender? <br>

<br> 2. Does the Merkle Proof match the stored Root? |
| **5.** | **Transfer** | If both checks pass, tokens are released according to the vesting schedule. |

---

## ⏳ Vesting & Mechanics

The contract implements a **Time-Lock Mechanism** to prevent immediate token dumping.

### 📅 Distribution Schedule

| Phase | Timeframe | Claimable Amount | Status |
| --- | --- | --- | --- |
| **1. TGE (Unlock)** | `Deployment` -> `30 Days` | **50%** (Instant) | 🟢 Active |
| **2. Cliff** | `30 Days` -> `90 Days` | **0%** (Locked) | 🟡 Holding |
| **3. Maturity** | `90 Days` -> `97 Days` | **Remaining 50%** | 🔵 Vesting |
| **4. Expiry** | `> 97 Days` | **0%** (Burn/Clawback) | 🔴 Closed |

---

## 🔐 Security Model

We utilize a multi-layered security approach to prevent common airdrop exploits.

* **🛡️ Merkle Proofs:** Ensures only addresses in the snapshot can claim. The root is immutable after deployment.
* **✍️ EIP-712 Signatures:** Prevents replay attacks across different chains or contracts. Users see a readable "Claim Airdrop" message in MetaMask instead of a hex string.
* **🚫 Double-Claim Protection:** A `BitMap` or mapping tracks claimed indices to ensure a leaf node cannot be reused.
* **🛑 Emergency Controls:** Owner can withdraw unclaimed tokens after the expiry window to prevent dust accumulation.

---

## 📂 Project Structure

A modular "Monorepo" style structure separating Contract Logic from Backend Utilities.

```bash
.
├── airdrop-data/          # 🧠 Off-Chain Logic
│   ├── input.json         # Raw list of eligible addresses
│   ├── merkle.js          # Script to generate Root & Proofs
│   └── backend/           # EIP-712 Signing Utilities
├── src/                   # ⛓️ On-Chain Logic
│   ├── SisoToken.sol      # The ERC20 Asset
│   └── MerkleAirdrop.sol  # The Distribution Logic
├── script/                # 🚀 Deployment & DevOps
│   ├── Deploy.s.sol       # Mainnet Deployment Script
│   └── Interact.s.sol     # Testing Interactions
└── test/                  # 🧪 Foundry Test Suite

```

---

## 🚀 Setup & Deployment

Designed for **Foundry**. No Hardhat required.

### 1. Installation

```bash
git clone [https://github.com/NexTechArchitect/Siso-Merkle-Airdrop](https://github.com/NexTechArchitect/Siso-Merkle-Airdrop)
cd Siso-Merkle-Airdrop
forge install
npm install # For Merkle generation scripts

```

### 2. Generate Merkle Root

```bash
# Process input.json and create the tree
node airdrop-data/merkle.js

```

### 3. Deploy to Sepolia

```bash
# Ensure your .env is configured
make deploy ARGS="--network sepolia"

```

---

<div align="center">





<b>Protocol Engineered by NexTechArchitect</b>





<i>Smart Contract Security • Foundry • Cryptography</i>






<a href="https://github.com/NexTechArchitect">
<img src="https://www.google.com/search?q=https://img.shields.io/badge/GitHub-181717%3Fstyle%3Dfor-the-badge%26logo%3Dgithub%26logoColor%3Dwhite" alt="GitHub"/>
</a>
&nbsp;&nbsp;
<a href="https://linkedin.com/in/amit-kumar-811a11277">
<img src="https://www.google.com/search?q=https://img.shields.io/badge/LinkedIn-0077B5%3Fstyle%3Dfor-the-badge%26logo%3Dlinkedin%26logoColor%3Dwhite" alt="LinkedIn"/>
</a>
&nbsp;&nbsp;
<a href="https://x.com/itZ_AmiT0">
<img src="https://www.google.com/search?q=https://img.shields.io/badge/X-000000%3Fstyle%3Dfor-the-badge%26logo%3Dx%26logoColor%3Dwhite" alt="X"/>
</a>

</div>

```

```
