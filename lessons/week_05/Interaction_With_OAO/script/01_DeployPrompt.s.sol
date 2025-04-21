// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Script, console } from "forge-std/Script.sol";
import { Prompt } from "../src/Prompt.sol";
import { IAIOracle } from "OAO/contracts/interfaces/IAIOracle.sol";

contract DeployPrompt is Script {
    address constant OAO_PROXY = 0x0A0f4321214BB6C7811dD8a71cF587bdaF03f0A0; // AI Oracle Proxy - Sepolia
    
    address deployerPublicKey;
    uint256 deployerPrivateKey;
    Prompt prompt;

    function setUp() public {
        deployerPublicKey = vm.envAddress("PUBLIC_KEY");
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);

        prompt = new Prompt(IAIOracle(OAO_PROXY));
        console.log("==promt addr=%s", address(prompt));

        vm.stopBroadcast();
    }
}

// source .env && forge script script/01_DeployPrompt.s.sol:DeployPrompt --rpc-url ${RPC_URL} --private-key ${DEPLOYER_PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${SCAN_API_KEY} -vvvv