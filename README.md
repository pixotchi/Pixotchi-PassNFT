
# PixotchiPassport NFT Contract

## Overview

The `PixotchiPassport` contract is an upgradeable ERC721-based NFT contract that allows users to mint and update NFTs using a signature-based mechanism. It leverages OpenZeppelin's upgradeable libraries and EIP-712 for secure signature verification.

## Features

- **Minting and Updating**: Users can mint new NFTs or update existing ones using signed vouchers.
- **Upgradeable**: The contract is designed to be upgradeable, ensuring future enhancements without disrupting the existing state.
- **Signature Verification**: Utilizes EIP-712 for secure and efficient signature verification.
- **Enumerable and URI Storage**: Extends `ERC721EnumerableUpgradeable` and `ERC721URIStorageUpgradeable` for enhanced functionality.

## Contract Details

### Structs

- **Plant**
  ```solidity
  struct Plant {
      uint256 id;
      uint256 level;
      uint256 score;
      string name;
      uint256 stars;
      uint256 timeUntilStarving;
      uint256 timePlantBorn;
      string strain;
      string ipfsHash;
      address owner;
      address contractAddress;
  }
  ```

- **Voucher**
  ```solidity
  struct Voucher {
      address wallet;
      Plant plant;
      uint256 nonce;
      uint256 optionalUpdateId;
      bool update;
  }
  ```

- **MemoryCard**
  ```solidity
  struct MemoryCard {
      string memoryCardUuid;
      string landUuid;
      string gardenUuid;
      string plotUuid;
      string salt;
      uint256 born;
      uint256 size;
  }
  ```

### Mappings

- `mapping(address => uint256) public nonce;`
- `mapping(uint256 => Plant) public plants;`
- `mapping(uint256 => MemoryCard) public memoryCards;`

### State Variables

- `address public signer;`
- `bool public enabled;`

### Events

- `event PlantMinted(address indexed to, uint256 indexed tokenId, Plant plant);`

### Functions

- **initialize**
  ```solidity
  function initialize(address _signer) initializer public;
  ```

- **setSigner**
  ```solidity
  function setSigner(address _signer) external onlyOwner;
  ```

- **signatureMint**
  ```solidity
  function signatureMint(Voucher memory _voucher, bytes memory signature) external nonReentrant;
  ```

- **signatureUpdate**
  ```solidity
  function signatureUpdate(Voucher memory _voucher, bytes memory signature) external nonReentrant;
  ```

- **tokenURI**
  ```solidity
  function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable) returns (string memory);
  ```

- **getIpfsHash**
  ```solidity
  function getIpfsHash(uint256 tokenId) external view returns (string memory);
  ```

- **getNonce**
  ```solidity
  function getNonce(address wallet) external view returns (uint256);
  ```

- **getPlant**
  ```solidity
  function getPlant(uint256 tokenId) external view returns (Plant memory);
  ```

- **getPlants**
  ```solidity
  function getPlants(uint256[] calldata tokenIds) external view returns (Plant[] memory);
  ```

- **getMemoryCard**
  ```solidity
  function getMemoryCard(uint256 tokenId) external view returns (MemoryCard memory);
  ```

### Internal Functions

- **_hash**
  ```solidity
  function _hash(Voucher memory _voucher) internal view returns (bytes32);
  ```

- **_verify**
  ```solidity
  function _verify(bytes32 digest, bytes memory signature) internal view returns (bool);
  ```

## Usage

### Deployment

1. Deploy the contract using a tool like Truffle or Hardhat.
2. Initialize the contract with the signer's address:
   ```solidity
   initialize(address _signer);
   ```

### Minting a New Token

1. Create a `Voucher` struct with the necessary plant data and nonce.
2. Sign the voucher off-chain using the signer's private key.
3. Call the `signatureMint` function with the voucher and signature:
   ```solidity
   signatureMint(Voucher memory _voucher, bytes memory signature);
   ```

### Updating an Existing Token

1. Create a `Voucher` struct with the updated plant data, nonce, and set `update` to `true`.
2. Sign the voucher off-chain using the signer's private key.
3. Call the `signatureUpdate` function with the voucher and signature:
   ```solidity
   signatureUpdate(Voucher memory _voucher, bytes memory signature);
   ```

## License

Licensed under the MIT License. See the `LICENSE` file at the project root for details.

---

**Built with ❤️ for the Pixotchi community**
