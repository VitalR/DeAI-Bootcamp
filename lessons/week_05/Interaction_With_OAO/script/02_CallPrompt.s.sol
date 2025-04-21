// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Script, console } from "forge-std/Script.sol";
import { Prompt } from "OAO/contracts/Prompt.sol";
import { IAIOracle } from "OAO/contracts/interfaces/IAIOracle.sol";

contract CallPrompt is Script {
    address constant PROMPT_CONTRACT = 0xe75af5294f4CB4a8423ef8260595a54298c7a2FB; // Prompt - Sepolia
    address constant OAO_PROXY = 0x0A0f4321214BB6C7811dD8a71cF587bdaF03f0A0; // AI Oracle Proxy - Sepolia

    uint256 deployerPrivateKey;
    Prompt prompt;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        prompt = Prompt(PROMPT_CONTRACT);
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);

        uint256 modelId = 11; // Llama3 8B Instruct
        // string memory userPrompt = "What is the capital of France?";
        string memory userPrompt2 = "What is the biggest city on the north of Black Sea?";

        // Step 1: Estimate the fee required for the transaction
        uint256 fee = prompt.estimateFee(modelId);
        console.log("Estimated fee: %s wei", fee);

        // Step 2: Call calculateAIResult with the prompt
        prompt.calculateAIResult{ value: fee }(modelId, userPrompt2);
        console.log("Prompt sent: %s", userPrompt2);

        vm.stopBroadcast();
    }
}

// source .env && forge script script/02_CallPrompt.s.sol:CallPrompt --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --gas-price ${GAS_PRICE} --gas-limit ${GAS_LIMIT} -vvvv
// https://sepolia.etherscan.io/tx/0x2d8b1c4004481afce8c7a43ad765badcc2f3c5833ded0839f3ea27d574d2a75b
// https://sepolia.etherscan.io/tx/0x20c5edc5d392d781e834875bc2848dda4c47711b5c2875db9361420c2b66a0cf