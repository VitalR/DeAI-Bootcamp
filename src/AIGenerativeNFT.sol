// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IAIOracle } from "OAO/contracts/interfaces/IAIOracle.sol";

/// @title AIGenerativeNFT - AI-NFT Collection powered by nested inference over OAO
/// @notice Uses LLaMA + Stable Diffusion via OAO to generate NFT content onchain
contract AIGenerativeNFT is ERC721, Ownable {
    IAIOracle public immutable aiOracle;
    uint256 public tokenCounter;

    uint256 public modelLLaMA;
    uint256 public modelSD;

    uint64 public constant MIN_GAS_LIMIT = 100_000;
    uint64 public constant MAX_GAS_LIMIT = 10_000_000;

    struct MintState {
        address user;
        string baseIdea;
        string prompt;
    }

    mapping(uint256 => MintState) public requestIdToState;
    mapping(uint256 => string) public tokenIdToImage;
    mapping(uint256 => string) public tokenIdToPrompt;
    mapping(uint256 => uint64) public callbackGasLimit;

    event PromptRequest(uint256 requestId, address sender, uint256 modelId, string prompt);
    event PromptsUpdated(uint256 requestId, uint256 modelId, string input, string output, bytes callbackData);
    event TokenMinted(address indexed user, uint256 indexed tokenId, string prompt, string imageUrl);

    constructor(address _owner, address _oracle, uint256 _modelLLaMA, uint256 _modelSD) ERC721("AI NFT Collection", "AINFT") Ownable(_owner) {
        aiOracle = IAIOracle(_oracle);
        modelLLaMA = _modelLLaMA;
        modelSD = _modelSD;
        callbackGasLimit[_modelLLaMA] = 5_000_000;
        callbackGasLimit[_modelSD] = 500_000;
    }

    /// @notice Admin function to update gas limit per model with safety check
    function setCallbackGasLimit(uint256 modelId, uint64 gasLimit) external onlyOwner {
        require(gasLimit >= MIN_GAS_LIMIT && gasLimit <= MAX_GAS_LIMIT, "Gas limit out of safe range");
        callbackGasLimit[modelId] = gasLimit;
    }

    /// @notice Estimates the total fee required for the full mint process
    function estimateTotalFee() external view returns (uint256 totalFee) {
        uint256 feeLLaMA = aiOracle.estimateFee(modelLLaMA, callbackGasLimit[modelLLaMA]);
        uint256 feeSD = aiOracle.estimateFee(modelSD, callbackGasLimit[modelSD]);
        return feeLLaMA + feeSD;
    }

    /// @notice Initiates prompt generation from LLaMA based on user idea
    function requestMint(string calldata idea) external payable {
        uint64 gasLimit = callbackGasLimit[modelLLaMA];
        uint256 requiredFee = aiOracle.estimateFee(modelLLaMA, gasLimit);
        require(msg.value >= requiredFee, "Insufficient fee sent");

        bytes memory input = bytes(idea);
        bytes memory callbackData = abi.encode(msg.sender, idea);

        uint256 requestId = aiOracle.requestCallback{value: requiredFee}(
            modelLLaMA,
            input,
            address(this),
            gasLimit,
            callbackData
        );

        // Refund excess
        if (msg.value > requiredFee) {
            payable(msg.sender).transfer(msg.value - requiredFee);
        }

        emit PromptRequest(requestId, msg.sender, modelLLaMA, idea);
    }

    /// @notice Handles both LLaMA and Stable Diffusion callbacks
    function aiOracleCallback(
        uint256 requestId,
        bytes calldata output,
        bytes calldata callbackData
    ) external {
        require(msg.sender == address(aiOracle), "Unauthorized oracle call");

        (address user, string memory ideaOrPrompt) = abi.decode(callbackData, (address, string));
        string memory result = string(output);

        if (bytes(requestIdToState[requestId].baseIdea).length == 0) {
            // Step 1: LLaMA callback
            requestIdToState[requestId] = MintState(user, ideaOrPrompt, result);

            bytes memory inputSD = bytes(string.concat("Generate image for: ", result));
            bytes memory nextCallbackData = abi.encode(user, result);
            uint64 gasLimit = callbackGasLimit[modelSD];

            uint256 requiredFee = aiOracle.estimateFee(modelSD, gasLimit);

            uint256 nextRequestId = aiOracle.requestCallback{value: requiredFee}(
                modelSD,
                inputSD,
                address(this),
                gasLimit,
                nextCallbackData
            );

            emit PromptRequest(nextRequestId, user, modelSD, string(inputSD));
            emit PromptsUpdated(requestId, modelLLaMA, ideaOrPrompt, result, callbackData);

        } else {
            // Step 2: Stable Diffusion callback
            MintState memory state = requestIdToState[requestId];
            uint256 tokenId = tokenCounter++;

            _safeMint(user, tokenId);
            tokenIdToPrompt[tokenId] = ideaOrPrompt;
            tokenIdToImage[tokenId] = result;

            emit PromptsUpdated(requestId, modelSD, ideaOrPrompt, result, callbackData);
            emit TokenMinted(user, tokenId, ideaOrPrompt, result);
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Nonexistent token");
        string memory image = tokenIdToImage[tokenId];
        string memory prompt = tokenIdToPrompt[tokenId];

        return string(
            abi.encodePacked(
                "data:application/json;utf8,",
                "{\"name\": \"AI NFT #",
                Strings.toString(tokenId),
                "\", \"description\": \"",
                prompt,
                "\", \"image\": \"",
                image,
                "\"}"
            )
        );
    }
}
