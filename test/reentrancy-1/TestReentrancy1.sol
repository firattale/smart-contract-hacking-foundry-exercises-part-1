// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {EtherBank} from "../../src/reentrancy-1/EtherBank.sol";
import {AttackBank} from "../../src/reentrancy-1/AttackBank.sol";

contract TestReentrancy1 is Test {
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address attacker = makeAddr("attacker");
    EtherBank etherBank;
    AttackBank attackBank;

    uint256 constant USER1_DEPOSIT = 12 ether;
    uint256 constant USER2_DEPOSIT = 6 ether;
    uint256 constant USER3_DEPOSIT = 28 ether;
    uint256 constant USER4_DEPOSIT = 63 ether;
    uint256 constant TOTAL_DEPOSIT = USER1_DEPOSIT + USER2_DEPOSIT + USER3_DEPOSIT + USER4_DEPOSIT;

    function setUp() public {
        vm.deal(user1, USER1_DEPOSIT);
        vm.deal(user2, USER2_DEPOSIT);
        vm.deal(user3, USER3_DEPOSIT);
        vm.deal(user4, USER4_DEPOSIT);
        vm.deal(attacker, 1 ether);

        vm.prank(deployer);
        etherBank = new EtherBank();

        vm.prank(user1);
        etherBank.depositETH{value: USER1_DEPOSIT}();

        vm.prank(user2);
        etherBank.depositETH{value: USER2_DEPOSIT}();

        vm.prank(user3);
        etherBank.depositETH{value: USER3_DEPOSIT}();

        vm.prank(user4);
        etherBank.depositETH{value: USER4_DEPOSIT}();

        assertEq(address(etherBank).balance, TOTAL_DEPOSIT);
    }

    function test_Hack() public {
        vm.startPrank(attacker);
        attackBank = new AttackBank{value: 1 ether}(address(etherBank));
        attackBank.attack();

        assertEq(attacker.balance, TOTAL_DEPOSIT + 1 ether);
    }
}
