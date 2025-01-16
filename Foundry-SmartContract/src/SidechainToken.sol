// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract SidechainToken is ERC20, Owned {
    error InvalidMinter();
    error MintingCapped();

    mapping(address => bool) public minters;
    uint256 public constant MINTING_CAP = 1_000_000_000e18;
    uint256 public totalMinted;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, 18) Owned(msg.sender) {
        minters[msg.sender] = true;
    }

    modifier onlyMinter() {
        if (!minters[msg.sender]) revert InvalidMinter();
        _;
    }

    function addMinter(address minter) external onlyOwner {
        minters[minter] = true;
    }

    function removeMinter(address minter) external onlyOwner {
        minters[minter] = false;
    }

    function mint(address to, uint256 amount) external onlyMinter {
        if (totalMinted + amount > MINTING_CAP) revert MintingCapped();
        totalMinted += amount;
        _mint(to, amount);
    }
}