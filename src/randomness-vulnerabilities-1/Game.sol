// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

/**
 * @title Game
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract Game {
    constructor() payable {}

    function play(uint256 guess) external {
        uint256 number = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, block.difficulty)));

        if (guess == number) {
            (bool sent,) = msg.sender.call{value: address(this).balance}("");
            require(sent, "Failed to send ETH");
        }
    }
}
