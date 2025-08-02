## MorphEcho Smart Contracts

This repository contains the Solidity smart contracts for the **MorphEcho** project.

#### WhisperNFT deployed to: [0x41B20e82DBFDe8557363Ca0B7C232C7288EA3Aae](https://explorer-holesky.morphl2.io/address/0x41B20e82DBFDe8557363Ca0B7C232C7288EA3Aae)

### What is MorphEcho?
------------------

MorphEcho is an app where people can share short, temporary thoughts or "whispers" with others nearby or interested in the same topics. To keep things anonymous and fun, an AI scrambles your message before it's shared. These whispers only last for a short time (like 24 hours) and then disappear.

You can find more details in the main project description.

### What's in this Repo?
--------------------

This specific repository focuses only on the **on-chain part** of MorphEcho – the core rules and storage for the whispers. It uses **Hardhat** for development and deployment.

Specifically, it includes:

1.  **WhisperNFT.sol**: The main smart contract. It defines a special kind of NFT (Non-Fungible Token) used for each whisper.
2.  **How Whispers Work (On-Chain):**
    *   **Minting**: When someone shares a whisper (after the AI scrambles it), a new NFT is created on the Morph blockchain. This NFT holds the scrambled message.
    *   **Temporary**: When minting, the creator chooses how long the whisper should last (up to a limit). After that time, the whisper is considered "expired".
    *   **Ephemeral (Disappearing)**: Once a whisper's time is up, anyone can trigger a function to "forget" it. This removes the scrambled message from the NFT, leaving only an empty placeholder. It's like the whisper has vanished.
    *   **Anonymous**: The NFT is owned by the person who shared it, but the scrambled message itself doesn't contain personal information. The AI scrambling is done off-chain _before_ the message reaches this contract.
    *   **Local/Interest Discovery**: (Planned for dApp) The NFTs can be found based on location or topics, although the core contract here just stores the basic whisper data and expiry time.
    *   **Burnable**: The owner of a whisper NFT can choose to "burn" it (delete it permanently) before it expires if they change their mind.

### Tech Stack

*   **Solidity**: The programming language for the smart contracts.
*   **Hardhat**: Development environment for compiling, testing, and deploying the contracts.
*   **OpenZeppelin**: Provides secure and standard building blocks (like the base ERC721 NFT contract).