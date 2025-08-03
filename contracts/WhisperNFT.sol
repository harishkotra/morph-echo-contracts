// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";

contract WhisperNFT is ERC721, ReentrancyGuard {
    // --- Constants ---
    uint256 public constant MAX_DURATION = 30 days;
    uint256 public constant MAX_TEXT_LENGTH = 1000;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MINT_COOLDOWN = 1 minutes;

    // --- State ---
    uint256 private _currentTokenId = 0;

    mapping(uint256 => string) private _whisperTexts;
    mapping(uint256 => uint256) private _expiryTimes;
    mapping(uint256 => bool) private _isForgotten;
    mapping(address => uint256) private _lastMintTime;

    // --- Events ---
    event WhisperMinted(uint256 indexed tokenId, address indexed minter, uint256 expiryTime);
    event WhisperForgotten(uint256 indexed tokenId);
    event WhisperBurned(uint256 indexed tokenId);

    // --- Modifiers ---
    modifier validTokenId(uint256 tokenId) {
        require(_ownerOf(tokenId) != address(0), "WhisperNFT: Token ID does not exist");
        _;
    }

    modifier onlyOwnerOf(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "WhisperNFT: Not token owner");
        _;
    }

    modifier onlyAccessible(uint256 tokenId) {
        require(block.timestamp < _expiryTimes[tokenId] && !_isForgotten[tokenId], "WhisperNFT: Not accessible");
        _;
    }

    constructor() ERC721("WhisperEcho", "WSPR") {}

    // --- Minting ---
    function mintWhisper(
        string memory _scrambledText,
        uint256 _durationSeconds
    ) public nonReentrant returns (uint256) {
        require(_durationSeconds > 0 && _durationSeconds <= MAX_DURATION, "WhisperNFT: Invalid duration");
        require(bytes(_scrambledText).length > 0 && bytes(_scrambledText).length <= MAX_TEXT_LENGTH, "WhisperNFT: Invalid text length");
        require(_currentTokenId < MAX_SUPPLY, "WhisperNFT: Max supply reached");
        require(block.timestamp > _lastMintTime[msg.sender] + MINT_COOLDOWN, "WhisperNFT: Mint cooldown active");

        _lastMintTime[msg.sender] = block.timestamp;
        uint256 newTokenId = ++_currentTokenId;

        _safeMint(msg.sender, newTokenId);

        _whisperTexts[newTokenId] = _scrambledText;
        _expiryTimes[newTokenId] = block.timestamp + _durationSeconds;
        _isForgotten[newTokenId] = false;

        emit WhisperMinted(newTokenId, msg.sender, _expiryTimes[newTokenId]);

        return newTokenId;
    }

    // --- Forget/Expire ---
    function forgetWhisper(uint256 tokenId) public validTokenId(tokenId) nonReentrant {
        if (_isForgotten[tokenId]) return;
        require(block.timestamp >= _expiryTimes[tokenId], "WhisperNFT: Cannot forget before expiry");

        delete _whisperTexts[tokenId];
        _isForgotten[tokenId] = true;

        emit WhisperForgotten(tokenId);
    }

    // --- Burn ---
    function burnWhisper(uint256 tokenId) public validTokenId(tokenId) onlyOwnerOf(tokenId) {
        _burn(tokenId);
        delete _whisperTexts[tokenId];
        delete _expiryTimes[tokenId];
        delete _isForgotten[tokenId];

        emit WhisperBurned(tokenId);
    }

    // --- View Functions ---
    function getWhisperText(uint256 tokenId)
        public
        view
        validTokenId(tokenId)
        onlyAccessible(tokenId)
        returns (string memory)
    {
        return _whisperTexts[tokenId];
    }

    function getExpiryTime(uint256 tokenId) public view validTokenId(tokenId) returns (uint256) {
        return _expiryTimes[tokenId];
    }

    function isWhisperExpired(uint256 tokenId) public view validTokenId(tokenId) returns (bool) {
        return block.timestamp >= _expiryTimes[tokenId];
    }

    function isWhisperForgotten(uint256 tokenId) public view validTokenId(tokenId) returns (bool) {
        return _isForgotten[tokenId];
    }

    /**
    * @dev Returns the total number of tokens minted so far.
    * This represents the current highest token ID.
    * @return The total supply.
    */
    function totalSupply() public view returns (uint256) {
        return _currentTokenId;
    }

    function tokenURI(uint256 tokenId) public view override validTokenId(tokenId) returns (string memory) {
        if (block.timestamp >= _expiryTimes[tokenId] || _isForgotten[tokenId]) {
            return "data:text/plain;charset=utf-8,This whisper has faded away.";
        }

        string memory text = _whisperTexts[tokenId];
        string memory encoded = Base64.encode(bytes(text));
        return string(abi.encodePacked("data:text/plain;base64,", encoded));
    }
}