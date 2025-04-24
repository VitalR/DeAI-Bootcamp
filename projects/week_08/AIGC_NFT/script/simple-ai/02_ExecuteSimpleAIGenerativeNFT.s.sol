// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Script, console } from "forge-std/Script.sol";
import { SimpleAIGenerativeNFT } from "../../src/SimpleAIGenerativeNFT.sol";

contract ExecuteSimpleAIGenerativeNFT is Script {
    address constant COLLECTION = 0xED6aE8CEEC65C9AAb767E68De9Dc9D59A85863Ae; // deployed address on Sepolia

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        SimpleAIGenerativeNFT nft = SimpleAIGenerativeNFT(COLLECTION);

        string memory idea = "A cyberpunk fox detective under neon rain";
        uint256 fee = nft.estimateTotalFee();
        console.log("Estimated total fee: %s wei", fee);

        nft.requestMint{ value: fee }(idea);
        console.log("Prompt submitted: %s", idea);

        vm.stopBroadcast();
    }
}

// source .env && forge script script/simple-ai/02_ExecuteSimpleAIGenerativeNFT.s.sol:ExecuteSimpleAIGenerativeNFT
// --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${SCAN_API_KEY} -vvvv
