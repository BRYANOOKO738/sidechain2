// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract TokenBridge is Owned {
    using SafeTransferLib for ERC20;

    error TransferAlreadyProcessed();
    error InvalidSignature();

    event TokensLocked(
        address indexed token,
        address indexed from,
        uint256 amount,
        bytes32 transferId
    );
    event TokensUnlocked(
        address indexed token,
        address indexed to,
        uint256 amount,
        bytes32 transferId
    );

    mapping(bytes32 => bool) public processedTransfers;
    mapping(address => bool) public supportedTokens;

    constructor() Owned(msg.sender) {}

    function addSupportedToken(address token) external onlyOwner {
        supportedTokens[token] = true;
    }

    function lockTokens(
        address token,
        uint256 amount,
        bytes32 transferId
    ) external {
        if (processedTransfers[transferId]) revert TransferAlreadyProcessed();
        if (!supportedTokens[token]) revert InvalidSignature();

        processedTransfers[transferId] = true;
        ERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        
        emit TokensLocked(token, msg.sender, amount, transferId);
    }

    function unlockTokens(
        address token,
        address to,
        uint256 amount,
        bytes32 transferId,
        bytes calldata signature
    ) external {
        if (processedTransfers[transferId]) revert TransferAlreadyProcessed();
        if (!_verifySignature(token, to, amount, transferId, signature))
            revert InvalidSignature();

        processedTransfers[transferId] = true;
        ERC20(token).safeTransfer(to, amount);
        
        emit TokensUnlocked(token, to, amount, transferId);
    }

    function _verifySignature(
        address token,
        address to,
        uint256 amount,
        bytes32 transferId,
        bytes calldata signature
    ) internal view returns (bool) {
        bytes32 message = keccak256(
            abi.encodePacked(token, to, amount, transferId)
        );
        bytes32 signedMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", message)
        );
        address signer = ecrecover(
            signedMessage,
            uint8(signature[0]),
            bytes32(signature[1:33]),
            bytes32(signature[33:65])
        );
        return signer == owner;
    }
}