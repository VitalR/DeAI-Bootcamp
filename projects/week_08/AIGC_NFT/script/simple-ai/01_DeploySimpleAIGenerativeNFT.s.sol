// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Script, console } from "forge-std/Script.sol";
import { SimpleAIGenerativeNFT } from "../../src/SimpleAIGenerativeNFT.sol";
import { IAIOracle } from "OAO/contracts/interfaces/IAIOracle.sol";

contract DeploySimpleAIGenerativeNFT is Script {
    address constant OAO_PROXY = 0x0A0f4321214BB6C7811dD8a71cF587bdaF03f0A0; // AI Oracle Proxy (Sepolia)
    uint256 constant MODEL_ID = 50; // e.g., Stable Diffusion
    uint64 constant CALLBACK_GAS_LIMIT = 500_000;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        SimpleAIGenerativeNFT collection =
            new SimpleAIGenerativeNFT(deployerAddress, OAO_PROXY, MODEL_ID, CALLBACK_GAS_LIMIT);

        console.log("SimpleAIGenerativeNFT deployed at :", address(collection));

        vm.stopBroadcast();
    }
}

// source .env && forge script script/simple-ai/01_DeploySimpleAIGenerativeNFT.s.sol:DeploySimpleAIGenerativeNFT
// --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${SCAN_API_KEY} -vvvv
// https://sepolia.etherscan.io/address/0xed6ae8ceec65c9aab767e68de9dc9d59a85863ae
