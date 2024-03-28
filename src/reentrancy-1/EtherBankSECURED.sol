// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title EtherBank
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
//PRotection 2: Reentrancy Guard
contract EtherBank is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function depositETH() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawETH() public nonReentrant {
        uint256 balance = balances[msg.sender];

        //Protection 1: CEI
        // Update Balance
        balances[msg.sender] = 0;

        // Send ETH
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Withdraw failed");
    }
}
