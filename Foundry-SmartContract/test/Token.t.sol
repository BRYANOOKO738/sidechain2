// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/SidechainToken.sol";

contract TokenTest is Test {
    SidechainToken token;
    address owner = address(this);
    address user = address(0x1);
    address minter = address(0x2);

    function setUp() public {
        token = new SidechainToken("Sidechain Token", "SCT");
    }

    function testMinting() public {
        token.addMinter(minter);
        vm.prank(minter);
        token.mint(user, 1000e18);
        assertEq(token.balanceOf(user), 1000e18);
    }

    function testMintingCap() public {
        vm.expectRevert(SidechainToken.MintingCapped.selector);
        token.mint(user, 1_000_000_001e18);
    }
}