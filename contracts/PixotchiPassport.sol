// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/// @title PixotchiPassport NFT Contract
/// @notice This contract allows users to mint PixotchiPassport NFTs using a signature-based mechanism.
/// @dev This contract uses EIP-712 for signature verification and extends ERC721EnumerableUpgradeable, EIP712Upgradeable, OwnableUpgradeable, and ReentrancyGuardUpgradeable. It is designed to be upgradeable using OpenZeppelin's upgradeable libraries.
contract PixotchiPassport is ERC721EnumerableUpgradeable, EIP712Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using ECDSA for bytes32;

    /// @notice Struct representing a Plant
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

    /// @notice Struct representing a Voucher
    struct Voucher {
        address wallet;
        Plant plant;
        uint256 nonce;
        uint256 optionalUpdateId;
        bool update;
    }

    /// @notice Struct representing a MemoryCard
    struct MemoryCard {
        /// @notice The UUID of the memory card. Because, you know, we need more unique identifiers in our lives.
        string memoryCardUuid;

        /// @notice The UUID of the land. Because just calling it "land" would be too simple.
        string landUuid;

        /// @notice The UUID of the garden. Because every garden needs its own UUID, obviously.
        string gardenUuid;

        /// @notice The UUID of the plot. Because distinguishing plots by their actual location is so last century.
        string plotUuid;

        /// @notice A pinch of salt. Because what's a memory card without a little seasoning?
        string salt;

        /// @notice The birth timestamp. Because even memory cards need to celebrate birthdays.
        uint256 born;

        /// @notice The size of the memory card. Because we need to know how much memory it has.
        uint256 size;
    }

    /// @notice Mapping from wallet address to nonce value
    mapping(address => uint256) public nonce;

    /// @notice Mapping from token ID to Plant struct
    mapping(uint256 => Plant) public plants;

    /// @notice Mapping from token ID to MemoryCard struct
    mapping(uint256 => MemoryCard) public memoryCards;

    /// @notice Address of the signer used for verifying signatures
    address public signer;

    /// @notice Indicates whether the claim functionality is currently enabled
    bool public enabled;

    /// @notice Event emitted when a new plant is minted
    /// @param to The address to which the token is minted
    /// @param tokenId The ID of the minted token
    /// @param plant The Plant struct associated with the minted token
    event PlantMinted(address indexed to, uint256 indexed tokenId, Plant plant);

    /// @notice Constructor to initialize the contract with a signer address
    /// @dev This function replaces the constructor in upgradeable contracts.
    /// @param _signer The address of the signer
    function initialize(address _signer) initializer public {
        __ERC721_init("ProofOfPlant", "PoP");
        __ERC721Enumerable_init();
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        __EIP712_init("PixotchiPassport", "1");
        signer = _signer;
        enabled = true;
    }

    /// @notice Sets the signer address
    /// @param _signer The new signer address
    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    /// @notice Mints a new token us<ing a signature-based voucher
    /// @param _voucher The voucher containing the plant data and nonce
    /// @param signature The signature to verify the voucher
    function signatureMint(
        Voucher memory _voucher,
        bytes memory signature
    ) external nonReentrant {
        require(enabled, "SignatureMint is disabled");
        require(!_voucher.update, "Use signatureUpdate for updates");
        require(_verify(_hash(_voucher), signature), "Invalid signature");
        require(_voucher.wallet == msg.sender, "Sender must equal voucher.wallet");
        require(signer != address(0), "Signer not set");
        require(nonce[_voucher.wallet] == _voucher.nonce, "Invalid nonce");

        uint256 tokenId = this.totalSupply();
        address to = msg.sender;

        plants[tokenId] = _voucher.plant;
        nonce[_voucher.wallet]++;
        _safeMint(to, tokenId);

        emit PlantMinted(to, tokenId, _voucher.plant);
    }

    /// @notice Updates an existing plant using a signature-based voucher
    /// @param _voucher The voucher containing the plant data and nonce
    /// @param signature The signature to verify the voucher
    function signatureUpdate(
        Voucher memory _voucher,
        bytes memory signature
    ) external nonReentrant {
        require(enabled, "SignatureUpdate is disabled");
        require(_voucher.update, "Use signatureMint for new mints");
        require(_verify(_hash(_voucher), signature), "Invalid signature");
        require(_voucher.wallet == msg.sender, "Sender must equal voucher.wallet");
        require(signer != address(0), "Signer not set");
        require(nonce[_voucher.wallet] == _voucher.nonce, "Invalid nonce");
        require(ownerOf(_voucher.optionalUpdateId) != address(0), "Token does not exist");

        uint256 tokenId = _voucher.optionalUpdateId;
        address to = msg.sender;

        plants[tokenId] = _voucher.plant;
        nonce[_voucher.wallet]++;

        emit PlantMinted(to, tokenId, _voucher.plant);
    }

    /// @notice Returns the token URI for a given token ID
    /// @param tokenId The ID of the token
    /// @return The token URI
    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable) returns (string memory) {
        return string(abi.encodePacked("ipfs://", plants[tokenId].ipfsHash));
    }

    /// @notice Returns the IPFS hash for a given token ID
    /// @param tokenId The ID of the token
    /// @return The IPFS hash
    function getIpfsHash(uint256 tokenId) external view returns (string memory) {
        return plants[tokenId].ipfsHash;
    }

    /// @notice Returns the nonce for a given wallet address
    /// @param wallet The address of the wallet
    /// @return The nonce value
    function getNonce(address wallet) external view returns (uint256) {
        return nonce[wallet];
    }

    /// @notice Returns the Plant struct for a given token ID
    /// @param tokenId The ID of the token
    /// @return The Plant struct
    function getPlant(uint256 tokenId) external view returns (Plant memory) {
        return plants[tokenId];
    }

    /// @notice Returns an array of Plant structs for given token IDs
    /// @param tokenIds The array of token IDs
    /// @return An array of Plant structs
    function getPlants(uint256[] calldata tokenIds) external view returns (Plant[] memory) {
        Plant[] memory plantArray = new Plant[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            plantArray[i] = plants[tokenIds[i]];
        }
        return plantArray;
    }

    /// @notice Returns the MemoryCard struct for a given token ID
    /// @param tokenId The ID of the token
    /// @return The MemoryCard struct
    function getMemoryCard(uint256 tokenId) external view returns (MemoryCard memory) {
        return memoryCards[tokenId];
    }
    /// @notice Hashes the voucher data
    /// @param _voucher The voucher to hash
    /// @return The hash of the voucher
    function _hash(Voucher memory _voucher) internal view returns (bytes32) {
        bytes32 plantHash = keccak256(abi.encode(
            keccak256("Plant(uint256 id,uint256 level,uint256 score,string name,uint256 stars,uint256 timeUntilStarving,uint256 timePlantBorn,string strain,string ipfsHash,address owner,address contractAddress)"),
            _voucher.plant.id,
            _voucher.plant.level,
            _voucher.plant.score,
            keccak256(bytes(_voucher.plant.name)),
            _voucher.plant.stars,
            _voucher.plant.timeUntilStarving,
            _voucher.plant.timePlantBorn,
            keccak256(bytes(_voucher.plant.strain)),
            keccak256(bytes(_voucher.plant.ipfsHash)),
            _voucher.plant.owner,
            _voucher.plant.contractAddress
        ));

        bytes32 voucherHash = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("Voucher(address wallet,Plant plant,uint256 nonce,uint256 optionalUpdateId,bool update)Plant(uint256 id,uint256 level,uint256 score,string name,uint256 stars,uint256 timeUntilStarving,uint256 timePlantBorn,string strain,string ipfsHash,address owner,address contractAddress)"),
            _voucher.wallet,
            plantHash,
            _voucher.nonce,
            _voucher.optionalUpdateId,
            _voucher.update
        )));
        return voucherHash;
    }

    /// @notice Verifies the signature of the voucher
    /// @param digest The hash of the voucher
    /// @param signature The signature to verify
    /// @return True if the signature is valid, false otherwise
    function _verify(bytes32 digest, bytes memory signature) internal view returns (bool) {
        return ECDSA.recover(digest, signature) == signer;
    }
}

