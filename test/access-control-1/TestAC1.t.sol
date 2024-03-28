// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface IProtocolVault {
    function withdrawETH() external;

    function owner() external returns (address);

    function _sendETH(address to) external;
}

contract AccessControlExercise1Test is Test {
    IProtocolVault private protocolVault;
    address private deployer;
    address private user1;
    address private user2;
    address private user3;
    address private attacker;
    uint256 private constant USER_DEPOSIT = 10 ether;
    uint256 private attackerInitialETHBalance;

    function setUp() public {
        // SETUP EXERCISE - DON'T CHANGE ANYTHING HERE
        deployer = address(this); // In Foundry, the deploying contract is the test contract itself
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        attacker = makeAddr("attacker");

        attackerInitialETHBalance = attacker.balance;

        //Due to incompatible solidity versions (0.4 v/s 0.8), we are directly deploying the
        //compiled bytecode on blockchain on behalf of deployer using "deployCode"
        vm.startPrank(deployer);
        address _attack = deployCode("ProtocolVault.sol:ProtocolVault");
        protocolVault = IProtocolVault(_attack);
        vm.stopPrank();

        vm.prank(user1);
        payable(address(protocolVault)).transfer(USER_DEPOSIT);

        vm.prank(user2);
        payable(address(protocolVault)).transfer(USER_DEPOSIT);

        vm.prank(user3);
        payable(address(protocolVault)).transfer(USER_DEPOSIT);

        uint256 currentBalance = address(protocolVault).balance;
        assertEq(currentBalance, USER_DEPOSIT * 3);

        vm.prank(attacker);
        vm.expectRevert();
        protocolVault.withdrawETH();
    }

    function testExploit() public {
        // CODE YOUR SOLUTION HERE
    }

    function tearDown() public view {
        // SUCCESS CONDITIONS

        // Protocol Vault is empty and attacker has ~30+ ETH
        assertEq(address(protocolVault).balance, 0);

        // It's difficult to account for exact transaction costs, hence the approximate check
        assertTrue(attacker.balance >= attackerInitialETHBalance + (USER_DEPOSIT * 3) - 0.2 ether);
    }
}
