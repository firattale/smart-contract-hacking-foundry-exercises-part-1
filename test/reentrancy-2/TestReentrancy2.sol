//  SPDX-License-Identifier: GPL-3.0-or-later
//   SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
//   https:smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {ApesAirdrop} from "../../src/reentrancy-2/ApesAirdrop.sol";
import {AttackApesAirdrop} from "../../src/reentrancy-2/AttackApesAirdrop.sol";

contract TestReentrancy2 is Test {
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address attacker = makeAddr("attacker");

    ApesAirdrop apesAirdrop;
    AttackApesAirdrop attackApesAirdrop;

    function setUp() public {
        address[] memory users = new address[](5);
        users[0] = user1;
        users[1] = user2;
        users[2] = user3;
        users[3] = user4;
        users[4] = attacker;

        vm.startPrank(deployer);

        apesAirdrop = new ApesAirdrop();
        apesAirdrop.addToWhitelist(users);

        for (uint256 index = 0; index < users.length; index++) {
            assertEq(apesAirdrop.isWhitelisted(users[index]), true);
        }

        vm.stopPrank();
    }

    function test_Hack() public {
        vm.startPrank(attacker);

        attackApesAirdrop = new AttackApesAirdrop(address(apesAirdrop));
        apesAirdrop.grantMyWhitelist(address(attackApesAirdrop));
        attackApesAirdrop.attack();

        vm.stopPrank();

        assertEq(apesAirdrop.balanceOf(address(attacker)), apesAirdrop.maxSupply());
    }
}
