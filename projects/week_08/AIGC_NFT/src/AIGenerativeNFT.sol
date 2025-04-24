// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IAIOracle } from "OAO/contracts/interfaces/IAIOracle.sol";
import { AIOracleCallbackReceiver } from "OAO/contracts/AIOracleCallbackReceiver.sol";

/// @title AIGenerativeNFT - AI-NFT Collection powered by nested inference over OAO
/// @notice Uses LLaMA + Stable Diffusion via OAO to generate NFT content onchain
/// @dev Relies on oracle callback with selector 0xb0347814 for nested inference chaining
contract AIGenerativeNFT is ERC721, Ownable, AIOracleCallbackReceiver {
    /// @notice Address that receives ETH fees from minting
    address public feeReceiver;

    /// @notice Flat minting fee in wei required from the caller
    uint256 public flatMintFee;

    /// @notice Counter for minted token IDs
    uint256 public tokenCounter;

    /// @notice Model ID for the LLaMA text model
    uint256 public modelLLaMA;

    /// @notice Model ID for the Stable Diffusion image model
    uint256 public modelSD;

    /// @notice Minimum allowed callback gas limit per model
    uint64 public constant MIN_GAS_LIMIT = 100_000;

    /// @notice Maximum allowed callback gas limit per model
    uint64 public constant MAX_GAS_LIMIT = 10_000_000;

    /// @notice Contract-level metadata URI for marketplaces like OpenSea
    string public baseContractURI;

    /// @notice Represents prompt state during multi-step inference
    struct MintState {
        address user;
        string baseIdea;
        string prompt;
    }

    /// @dev Tracks inference request state
    mapping(uint256 => MintState) public requestIdToState;

    /// @dev Maps tokenId to generated image URL
    mapping(uint256 => string) public tokenIdToImage;

    /// @dev Maps tokenId to generated prompt text
    mapping(uint256 => string) public tokenIdToPrompt;

    /// @dev Gas limits for each model
    mapping(uint256 => uint64) public callbackGasLimit;

    /// @notice Caches image URL for each unique prompt submitted
    /// @dev Enables prompt reuse and lookup without re-minting
    mapping(string => string) public promptOutputs;

    /// @notice Emitted when an AI prompt is submitted
    event PromptRequest(uint256 requestId, address sender, uint256 modelId, string prompt);

    /// @notice Emitted when a model returns a result
    event PromptsUpdated(uint256 requestId, uint256 modelId, string input, string output, bytes callbackData);

    /// @notice Emitted when a token is minted successfully
    event TokenMinted(address indexed user, uint256 indexed tokenId, string prompt, string imageUrl);

    /// @notice Emitted when the fee receiver address is updated
    /// @param newReceiver The new address set to receive fees
    event FeeReceiverUpdated(address indexed newReceiver);

    /// @notice Emitted when the flat mint fee amount is updated
    /// @param newFee The updated flat fee amount in wei
    event MintFeeUpdated(uint256 newFee);

    /// @notice Emitted when the accumulated ETH fees are withdrawn
    /// @param to The address that received the withdrawn funds
    /// @param amount The amount of ETH withdrawn
    event FeeWithdrawn(address indexed to, uint256 amount);

    /// @param _owner The initial owner of the contract
    /// @param _oracle Address of the deployed AIOracle
    /// @param _modelLLaMA ID of the LLaMA model
    /// @param _modelSD ID of the Stable Diffusion model
    constructor(address _owner, address _oracle, uint256 _modelLLaMA, uint256 _modelSD)
        ERC721("AI NFT Collection", "AINFT")
        Ownable(_owner)
        AIOracleCallbackReceiver(IAIOracle(_oracle))
    {
        modelLLaMA = _modelLLaMA;
        modelSD = _modelSD;
        callbackGasLimit[_modelLLaMA] = 5_000_000;
        callbackGasLimit[_modelSD] = 500_000;
        feeReceiver = _owner;
    }

    /// @notice Admin function to update gas limit for a given model
    /// @param _modelId The model ID to configure
    /// @param _gasLimit The gas limit for callback execution
    function setCallbackGasLimit(uint256 _modelId, uint64 _gasLimit) external onlyOwner {
        require(_gasLimit >= MIN_GAS_LIMIT && _gasLimit <= MAX_GAS_LIMIT, "Gas limit out of safe range");
        callbackGasLimit[_modelId] = _gasLimit;
    }

    /// @notice Estimate the total fee required to run both LLaMA and SD models
    /// @return _totalFee The estimated fee in wei
    function estimateTotalFee() public view returns (uint256 _totalFee) {
        uint256 feeLLaMA = aiOracle.estimateFee(modelLLaMA, callbackGasLimit[modelLLaMA]);
        uint256 feeSD = aiOracle.estimateFee(modelSD, callbackGasLimit[modelSD]);
        return feeLLaMA + feeSD + flatMintFee;
    }

    /// @notice Initiates AI prompt generation based on user input
    /// @param _idea The base _idea for the NFT (textual description)
    function requestMint(string calldata _idea) external payable {
        uint64 gasLimit = callbackGasLimit[modelLLaMA];
        uint256 requiredFee = estimateTotalFee(); //aiOracle.estimateFee(modelLLaMA, gasLimit);
        require(msg.value >= requiredFee, "Insufficient fee sent");

        bytes memory input = bytes(_idea);
        bytes memory callbackData = abi.encode(msg.sender, _idea);

        uint256 requestId =
            aiOracle.requestCallback{ value: requiredFee }(modelLLaMA, input, address(this), gasLimit, callbackData);

        if (msg.value > requiredFee) {
            payable(msg.sender).transfer(msg.value - requiredFee);
        }

        emit PromptRequest(requestId, msg.sender, modelLLaMA, _idea);
    }

    /// @notice Oracle callback handler for multi-stage AI inference (text → prompt → image → mint)
    /// @dev Handles LLaMA output in first stage, then Stable Diffusion output in second stage
    /// @param _requestId The unique ID of the completed inference request
    /// @param _output The output of the AI model (either a refined prompt or image URL)
    /// @param _callbackData ABI-encoded user context: original prompt and address
    function aiOracleCallback(uint256 _requestId, bytes calldata _output, bytes calldata _callbackData)
        external
        override
        onlyAIOracleCallback
    {
        (address user, string memory ideaOrPrompt) = abi.decode(_callbackData, (address, string));
        string memory result = string(_output);

        if (bytes(requestIdToState[_requestId].baseIdea).length == 0) {
            // Step 1: LLaMA output received
            requestIdToState[_requestId] = MintState(user, ideaOrPrompt, result);

            bytes memory inputSD = bytes(string.concat("Generate image for: ", result));
            bytes memory nextCallbackData = abi.encode(user, result);
            uint64 gasLimit = callbackGasLimit[modelSD];

            uint256 requiredFee = aiOracle.estimateFee(modelSD, gasLimit);

            uint256 nextRequestId = aiOracle.requestCallback{ value: requiredFee }(
                modelSD, inputSD, address(this), gasLimit, nextCallbackData
            );

            emit PromptRequest(nextRequestId, user, modelSD, string(inputSD));
            emit PromptsUpdated(_requestId, modelLLaMA, ideaOrPrompt, result, _callbackData);
        } else {
            // Step 2: Stable Diffusion output received → Mint NFT
            uint256 tokenId = tokenCounter++;

            _safeMint(user, tokenId);
            tokenIdToPrompt[tokenId] = ideaOrPrompt;
            tokenIdToImage[tokenId] = result;
            promptOutputs[ideaOrPrompt] = result;

            emit PromptsUpdated(_requestId, modelSD, ideaOrPrompt, result, _callbackData);
            emit TokenMinted(user, tokenId, ideaOrPrompt, result);
        }
    }

    /// @notice Sets the fee receiver address for ETH collected via flat mint fees
    /// @param newReceiver The address to receive accumulated mint fees
    function setFeeReceiver(address newReceiver) external onlyOwner {
        require(newReceiver != address(0), "Invalid receiver");
        feeReceiver = newReceiver;
        emit FeeReceiverUpdated(newReceiver);
    }

    /// @notice Sets the flat ETH mint fee required in addition to oracle fees
    /// @param fee The new flat fee in wei
    function setMintFee(uint256 fee) external onlyOwner {
        flatMintFee = fee;
        emit MintFeeUpdated(fee);
    }

    /// @notice Withdraws accumulated ETH mint fees to the fee receiver address
    /// @dev Only callable by the designated feeReceiver
    function withdrawFees() external {
        require(msg.sender == feeReceiver, "Only fee receiver");
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance");
        payable(feeReceiver).transfer(balance);
        emit FeeWithdrawn(feeReceiver, balance);
    }

    /// @notice Admin function to set collection-level metadata URI
    /// @param _uri The OpenSea-style metadata URI
    function setContractURI(string memory _uri) external onlyOwner {
        baseContractURI = _uri;
    }

    /// @notice Returns collection-level metadata URI
    /// @return Contract-level metadata URI string
    function contractURI() external view returns (string memory) {
        return baseContractURI;
    }

    /// @notice Returns on-chain metadata for the NFT (OpenSea-compatible)
    /// @param _tokenId The ID of the token
    /// @return A base64-encoded JSON metadata string
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(ownerOf(_tokenId) != address(0), "Nonexistent token");
        string memory image = tokenIdToImage[_tokenId];
        string memory prompt = tokenIdToPrompt[_tokenId];

        return string(
            abi.encodePacked(
                "data:application/json;utf8,",
                "{\"name\": \"AI NFT #",
                Strings.toString(_tokenId),
                "\", \"description\": \"",
                prompt,
                "\", \"image\": \"",
                image,
                "\", \"attributes\": [{\"trait_type\": \"Model\", \"value\": \"LLaMA + SD\"}]}"
            )
        );
    }
}
