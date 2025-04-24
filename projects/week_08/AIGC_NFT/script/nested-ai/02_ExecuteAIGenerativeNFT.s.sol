// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Script, console } from "forge-std/Script.sol";
import { AIGenerativeNFT } from "../src/AIGenerativeNFT.sol";

contract ExecuteAIGenerativeNFT is Script {
    address constant NFT_CONTRACT = 0x978Af172AE31B79ebeBFE0A6b0D7a294F0369f3b;

    uint256 privateKey;
    AIGenerativeNFT nft;

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        nft = AIGenerativeNFT(NFT_CONTRACT);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        string memory idea = "A cozy cabin in the snowy woods, with a warm glow inside";

        uint256 totalFee = nft.estimateTotalFee();
        console.log("Estimated total fee (LLaMA + SD + flatMintFee): %s wei", totalFee);

        nft.requestMint{ value: totalFee }(idea);
        console.log("Requested mint with idea: %s", idea);

        vm.stopBroadcast();
    }
}

// source .env && forge script script/nested-ai/02_ExecuteAIGenerativeNFT.s.sol:ExecuteAIGenerativeNFT --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${SCAN_API_KEY} -vvvv
