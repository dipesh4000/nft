# 🧠 ZKP Verified NFT (ZKPMerkleNFT)

**Deployed Address:** `0x66FC05Cea3cF247026dd93db9c93Cb5Ea1F08B9B`

A lightweight **Zero-Knowledge Proof (ZKP)**-inspired NFT minting contract built in **Solidity** with **no imports** and **no constructors**.  
Verified users can mint NFTs using a **Merkle proof** that demonstrates membership in a pre-approved (off-chain verified) list — without revealing any private data.

---

## 🚀 Overview

This smart contract allows **only verified users** to mint a unique NFT after providing a valid **Merkle proof** that confirms their address exists in a whitelist managed off-chain.  
Each verified user can mint exactly **one NFT**, which acts as a **badge of authenticity** or **ZKP-based identity token**.

This is a simplified on-chain zero-knowledge mechanism using Merkle membership proofs — **gas-efficient**, **fully self-contained**, and **requires no external verifier contracts**.

---

## ✨ Features

- ✅ **Zero imports** — pure Solidity 0.8.20  
- 🏗️ **No constructor** — initialized via `initialize()`  
- 🔐 **Merkle-tree proof verification** for ZKP-style membership  
- 🎟️ **One NFT per verified address**  
- 🧑‍💼 **Admin controls** for Merkle root updates & airdrops  
- 🖼️ **Minimal ERC-721-compatible functions** (transfer, approve, tokenURI)  
- 🪶 **Lightweight & gas-optimized**

---

## 🧩 Contract Summary

**Contract Name:** `ZKPMerkleNFT`  
**Symbol:** `ZKPV`  
**Language:** Solidity ^0.8.20  
**Imports:** None  
**Constructor:** None (uses `initialize()` function)