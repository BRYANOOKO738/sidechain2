// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/TokenBridge.sol";
import "../src/SidechainToken.sol";

contract BridgeTest is Test {
    TokenBridge bridge;
    SidechainToken token;
    address owner = address(this);
    address user = address(0x1);

    function setUp() public {
        bridge = new TokenBridge();
        token = new SidechainToken("Sidechain Token", "SCT");
        bridge.addSupportedToken(address(token));
    }

    function testLockTokens() public {
        bytes32 transferId = keccak256("test");
        uint256 amount = 1000e18;

        token.mint(user, amount);
        vm.startPrank(user);
        token.approve(address(bridge), amount);
        bridge.lockTokens(address(token), amount, transferId);
        vm.stopPrank();

        assertEq(token.balanceOf(address(bridge)), amount);
    }
}
