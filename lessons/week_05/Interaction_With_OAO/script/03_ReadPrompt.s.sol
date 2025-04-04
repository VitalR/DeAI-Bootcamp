// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Script, console } from "forge-std/Script.sol";
import { Prompt } from "OAO/contracts/Prompt.sol";

contract ReadPrompt is Script {
    address constant PROMPT_CONTRACT = 0xe75af5294f4CB4a8423ef8260595a54298c7a2FB;

    function run() public view {
        Prompt prompt = Prompt(PROMPT_CONTRACT);

        uint256 modelId = 11;
        // string memory userPrompt = "What is the capital of France?";
        string memory userPrompt2 = "What is the biggest city on the north of Black Sea?";

        string memory result = prompt.getAIResult(modelId, userPrompt2);
        console.log("Prompt: %s", userPrompt2);
        console.log("AI Response: %s", result);
    }
}

// source .env && forge script script/03_ReadPrompt.s.sol:ReadPrompt --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --broadcast -vvvv
