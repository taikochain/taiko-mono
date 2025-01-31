---
title: What is Taiko Alethia?
description: Core concept page for "What is Taiko Alethia?".
---

Ethereum is **expensive** and **congested**. However, Ethereum's core principles—**censorship resistance, permissionless access, and robust security**—are **non-negotiable**. A true scaling solution must **extend** these properties without introducing trust assumptions, centralization, or trade-offs.

## Introducing Taiko Alethia

Taiko Alethia is an **Ethereum-equivalent, permissionless, based rollup** designed to scale Ethereum without compromising its fundamental properties. Unlike traditional rollups that rely on centralized sequencers, Taiko Alethia leverages Ethereum itself for sequencing, ensuring that block ordering is decentralized and censorship-resistant.

### Key Concepts in Taiko Alethia

- [Based rollup](/core-concepts/based-rollups): A rollup where Ethereum L1 validators sequence blocks, removing the need for a centralized sequencer.
- [Based contestable rollup](/core-concepts/contestable-rollup): A configurable, multi-proof rollup with hierarchical proving mechanisms to enhance security.
- [Based booster rollup](/core-concepts/booster-rollups): Native L1 scaling via Ethereum-equivalent L2.

## How Taiko Alethia Works

At its core, Taiko Alethia is a set of smart contracts deployed on Ethereum L1 that enforce execution rules, manage proofs, and facilitate rollup operations.

- **Proposing blocks**: Transactions are proposed permissionlessly by anyone following Ethereum’s sequencing rules.
- **Proving blocks**: Provers submit validity proofs (ZK, TEE, or Guardian) to confirm the correctness of proposed blocks.
- **Verification & contestation**: If a proof is contested, a higher-tier proof can be submitted to verify or dispute the original proof.

---

## Taiko Alethia Governance & Organizations

### Decentralized Organizations

Taiko Alethia operates as a fully decentralized protocol governed by **DAOs, community-run validators, and decentralized incentives**.

| Organization                | Functionality                                                                            |
| --------------------------- | ---------------------------------------------------------------------------------------- |
| **Taiko Community**         | Open social groups and discussions (Discord, Twitter, forums).                           |
| **Taiko Labs**              | Research and development entity supporting the Taiko Alethia protocol.                   |
| **Taiko Treasury**          | Collects fees from L2 congestion pricing and distributes funds for development.          |
| **Taiko DAO (in progress)** | Governing body managing smart contract upgrades, network parameters, and protocol funds. |
| **Taiko Foundation**        | Funds technical development, partnerships, and ecosystem growth.                         |
| **Taiko Security Council**  | Handles critical protocol security, Guardian Provers, and emergency network decisions.   |

---

## Infrastructure Operated by Taiko Labs

Taiko Labs operates non-critical and critical infrastructure, but anyone can run these components due to Taiko’s open-source and permissionless nature.

### Non-Critical Infrastructure

These services are open-source, meaning anyone can replicate or improve them.

#### Frontends

- [Bridge UI](https://bridge.taiko.xyz) → Interface for asset transfers between L1 & L2.
- [Network status](https://status.taiko.xyz) → Live updates on Taiko Alethia.
- [Homepage & Documentation](https://taiko.xyz) → Official website and developer resources.
- [Geth fork diff](https://geth.taiko.xyz) → Fork comparison for Ethereum-equivalence.

#### Backends

- [Event Indexer](/api-reference/event-indexer) → Tracks rollup transactions & events.
- [Bridge Relayer](/api-reference/bridge-relayer) → Facilitates trust-minimized bridging.
- **Taiko Alethia & Hekla P2P Bootstrapping Nodes** → Helps decentralized peers sync with the network.
- **Taiko Alethia & Hekla Proposers & Provers** → Supports decentralized block production.

### Critical Infrastructure

🚨 These components are trusted until full decentralization is achieved via the DAO. 🚨

- [Taiko Alethia contract owners](/network-reference/alethia-addresses#contract-owners)
- [Taiko Hekla contract owners](/network-reference/hekla-addresses#contract-owners)

Taiko Alethia is actively **transitioning towards full decentralization**, following **Ethereum's rollup-centric roadmap**.

---
