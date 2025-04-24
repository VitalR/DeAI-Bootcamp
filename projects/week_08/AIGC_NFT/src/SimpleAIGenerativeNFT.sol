// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IAIOracle } from "OAO/contracts/interfaces/IAIOracle.sol";
import { AIOracleCallbackReceiver } from "OAO/contracts/AIOracleCallbackReceiver.sol";

/// @title SimpleAIGenerativeNFT - One-step AI NFT collection (Text → Image)
contract SimpleAIGenerativeNFT is ERC721, Ownable, AIOracleCallbackReceiver {
    uint256 public modelId;
    uint64 public callbackGasLimit;
    address public feeReceiver;
    uint256 public flatMintFee;
    uint256 public tokenCounter;

    mapping(uint256 => string) public tokenIdToPrompt;
    mapping(uint256 => string) public tokenIdToImage;

    /// @notice modelID => prompt => outputURL
    mapping(uint256 => mapping(string => string)) public prompts;

    event PromptRequested(uint256 indexed requestId, address indexed sender, string prompt);
    event TokenMinted(address indexed user, uint256 indexed tokenId, string prompt, string imageUrl);

    constructor(
        address _owner,
        address _oracle,
        uint256 _modelId,
        uint64 _callbackGasLimit
    )
        ERC721("AI NFT Collection", "AINFT")
        Ownable(_owner)
        AIOracleCallbackReceiver(IAIOracle(_oracle))
    {
        modelId = _modelId;
        callbackGasLimit = _callbackGasLimit;
        feeReceiver = _owner;
    }

    function estimateTotalFee() public view returns (uint256) {
        return aiOracle.estimateFee(modelId, callbackGasLimit) + flatMintFee;
    }

    function requestMint(string calldata prompt) external payable {
        uint256 requiredFee = estimateTotalFee();
        require(msg.value >= requiredFee, "Not enough ETH");

        bytes memory input = bytes(prompt);
        bytes memory callbackData = abi.encode(msg.sender, prompt);

        uint256 requestId =
            aiOracle.requestCallback{ value: requiredFee }(modelId, input, address(this), callbackGasLimit, callbackData);

        emit PromptRequested(requestId, msg.sender, prompt);

        if (msg.value > requiredFee) {
            payable(msg.sender).transfer(msg.value - requiredFee);
        }
    }

    function aiOracleCallback(
        uint256, // requestId unused
        bytes calldata _output,
        bytes calldata _callbackData
    ) external override onlyAIOracleCallback {
        (address user, string memory prompt) = abi.decode(_callbackData, (address, string));
        string memory imageUrl = string(_output);

        uint256 tokenId = tokenCounter++;

        _safeMint(user, tokenId);
        tokenIdToPrompt[tokenId] = prompt;
        tokenIdToImage[tokenId] = imageUrl;
        prompts[modelId][prompt] = imageUrl;

        emit TokenMinted(user, tokenId, prompt, imageUrl);
    }

    function getAIResult(uint256 _modelId, string calldata prompt) external view returns (string memory) {
        return prompts[_modelId][prompt];
    }

    function setMintFee(uint256 fee) external onlyOwner {
        flatMintFee = fee;
    }

    function setFeeReceiver(address receiver) external onlyOwner {
        require(receiver != address(0), "Invalid address");
        feeReceiver = receiver;
    }

    function withdrawFees() external {
        require(msg.sender == feeReceiver, "Only feeReceiver");
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance");
        payable(feeReceiver).transfer(balance);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Nonexistent token");

        string memory prompt = tokenIdToPrompt[tokenId];
        string memory image = tokenIdToImage[tokenId];

        return string(
            abi.encodePacked(
                "data:application/json;utf8,",
                "{\"name\": \"AI NFT #",
                Strings.toString(tokenId),
                "\", \"description\": \"",
                prompt,
                "\", \"image\": \"",
                image,
                "\", \"attributes\": [{\"trait_type\": \"Model\", \"value\": \"",
                Strings.toString(modelId),
                "\"}]}"
            )
        );
    }
}
