// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

//Protection 2: Reentrancy Guard

contract EtherBankSecured is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function depositETH() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawETH() public nonReentrant {
        uint256 balance = balances[msg.sender];

        //Protection 1 Apply CEI
        // Update Balance
        balances[msg.sender] = 0;

        // Send ETH
        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Withdraw failed");
    }
}
