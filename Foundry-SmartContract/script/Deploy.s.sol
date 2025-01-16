// contracts/script/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/SidechainToken.sol";
import "../src/TokenBridge.sol";

contract DeployScript is Script {
    function run() external {
       
        uint256 deployerPrivateKey = 0x76d31acf58ccc92f5f22f8b386bf6cfb4d81dbe5a12b5000d41054b39c4b51ea; // Replace with your private key

        vm.startBroadcast(deployerPrivateKey);

        // Deploy token
        SidechainToken token = new SidechainToken(
            "Sidechain Token",
            "SCT"
        );

        // Deploy bridge
        TokenBridge bridge = new TokenBridge();
        
        // Setup
        token.addMinter(address(bridge));
        bridge.addSupportedToken(address(token));

        vm.stopBroadcast();

        // Log addresses
        console.log("Token deployed to:", address(token));
        console.log("Bridge deployed to:", address(bridge));
    }
}