// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MyToken} from "../../src/erc20-1/Mytoken.sol";

import "forge-std/Test.sol";

contract TestERC201 is Test {
    MyToken mytoken;
    address deployer;
    address user1;
    address user2;
    address user3;

    uint256 constant TEN_K = 100000;
    uint256 constant FIVE_K = 5000;

    function setUp() public {
        mytoken = new MyToken();
        deployer = makeAddr("deployer");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        mytoken.mint(deployer, TEN_K);
        mytoken.mint(user1, FIVE_K);
        mytoken.mint(user2, FIVE_K);
        mytoken.mint(user3, FIVE_K);
    }

    function testCheckBalances() public view {
        assertEq(mytoken.balanceOf(deployer), TEN_K);
        assertEq(mytoken.balanceOf(user1), FIVE_K);
        assertEq(mytoken.balanceOf(user2), FIVE_K);
        assertEq(mytoken.balanceOf(user3), FIVE_K);
    }

    function testAllowances() public {
        vm.prank(user2);
        mytoken.transfer(user3, 100);

        vm.prank(user3);
        mytoken.approve(user1, 1000);

        assertEq(mytoken.allowance(user3, user1), 1000);

        vm.prank(user1);
        mytoken.transferFrom(user3, user1, 1000);

        assertEq(mytoken.balanceOf(user1), 6000);
        assertEq(mytoken.balanceOf(user2), 4900);
        assertEq(mytoken.balanceOf(user3), 4100);
    }
}
