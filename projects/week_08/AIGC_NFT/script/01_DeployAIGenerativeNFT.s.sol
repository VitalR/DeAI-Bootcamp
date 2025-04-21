// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Script, console } from "forge-std/Script.sol";
import { AIGenerativeNFT } from "../src/AIGenerativeNFT.sol";
import { IAIOracle } from "OAO/contracts/interfaces/IAIOracle.sol";

contract DeployAIGenerativeNFT is Script {
    address constant OAO_PROXY = 0x0A0f4321214BB6C7811dD8a71cF587bdaF03f0A0; // AI Oracle Proxy - Sepolia
    uint256 constant MODEL_LLAMA = 11;
    uint256 constant MODEL_SD = 50;

    address deployerPublicKey;
    uint256 deployerPrivateKey;
    AIGenerativeNFT nft;

    function setUp() public {
        deployerPublicKey = vm.envAddress("PUBLIC_KEY");
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);

        nft = new AIGenerativeNFT(
            deployerPublicKey,
            OAO_PROXY,
            MODEL_LLAMA,
            MODEL_SD
        );

        console.log("== AIGenerativeNFT deployed at: %s", address(nft));

        vm.stopBroadcast();
    }
}

// source .env && forge script script/01_DeployAIGenerativeNFT.s.sol:DeployAIGenerativeNFT --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${SCAN_API_KEY} -vvvv