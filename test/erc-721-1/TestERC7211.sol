// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {MyToken} from "../../src/erc721-1/MyToken.sol";

contract TestERC7211 is Test {
    MyToken public myTokenNFT;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() public {
        myTokenNFT = new MyToken();
        vm.deal(deployer, 10 ether);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function test_mint() public {
        vm.startPrank(deployer);
        myTokenNFT.mint{value: 0.1 ether}();
        myTokenNFT.mint{value: 0.1 ether}();
        myTokenNFT.mint{value: 0.1 ether}();
        myTokenNFT.mint{value: 0.1 ether}();
        myTokenNFT.mint{value: 0.1 ether}();
        vm.stopPrank();

        vm.startPrank(user1);
        myTokenNFT.mint{value: 0.1 ether}();
        myTokenNFT.mint{value: 0.1 ether}();
        myTokenNFT.mint{value: 0.1 ether}();
        vm.stopPrank();

        assertEq(myTokenNFT.balanceOf(deployer), 5);
        assertEq(myTokenNFT.balanceOf(user1), 3);
        assertEq(myTokenNFT.balanceOf(user2), 0);

        vm.startPrank(user1);
        myTokenNFT.transferFrom(user1, user2, 6);
        vm.stopPrank();

        assertEq(myTokenNFT.ownerOf(6), user2);

        vm.startPrank(deployer);
        myTokenNFT.approve(user1, 3);
        vm.stopPrank();

        assertEq(myTokenNFT.getApproved(3), user1);

        vm.startPrank(user1);
        myTokenNFT.transferFrom(deployer, user1, 3);
        vm.stopPrank();
        assertEq(myTokenNFT.ownerOf(3), user1);

        assertEq(myTokenNFT.balanceOf(deployer), 4);
        assertEq(myTokenNFT.balanceOf(user1), 3);
        assertEq(myTokenNFT.balanceOf(user2), 1);
    }
}
