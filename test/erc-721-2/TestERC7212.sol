// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {OpenOcean} from "../../src/erc721-2/OpenOcean.sol";
import {DummyERC721} from "../../src/utils/DummyERC721.sol";
/**
 * @dev run "forge test --match-contract ERC7212"
 */

contract TestERC7212 is Test {
    address deployer;
    address user1;
    address user2;
    address user3;
    DummyERC721 cuteNFT;
    DummyERC721 booblesNFT;
    OpenOcean marketplace;

    uint256 constant INITIAL_BALANCE = 100 ether;

    function setUp() public {
        deployer = makeAddr("deployer");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        vm.deal(user1, INITIAL_BALANCE);
        vm.deal(user2, INITIAL_BALANCE);
        vm.deal(user3, INITIAL_BALANCE);

        // User1 creates his own NFT collection
        vm.startPrank(user1);
        cuteNFT = new DummyERC721("Crypto Cuties", "CUTE", 1000);
        cuteNFT.mintBulk(30);
        vm.stopPrank();

        assertEq(cuteNFT.balanceOf(user1), 30);

        // User3 creates his own NFT collection
        vm.startPrank(user3);
        booblesNFT = new DummyERC721("Rare Boobles", "BOO", 10000);
        booblesNFT.mintBulk(120);
        vm.stopPrank();

        assertEq(booblesNFT.balanceOf(user3), 120);
    }

    function test_Listing_and_Purchasing() public {
        vm.startPrank(deployer);
        marketplace = new OpenOcean();
        vm.stopPrank();

        vm.startPrank(user1);
        DummyERC721(address(cuteNFT)).setApprovalForAll(address(marketplace), true);
        for (uint256 index = 1; index < 11; index++) {
            marketplace.listItem(address(cuteNFT), index, 5 ether);
        }
        vm.stopPrank();

        assertEq(marketplace.itemsCounter(), 10);
        assertEq(DummyERC721(address(cuteNFT)).balanceOf(address(marketplace)), 10);

        // Retrieve the last listed item
        OpenOcean.Item memory lastItem = marketplace.getItem(10);

        assertEq(lastItem.itemId, 10);
        assertEq(lastItem.collectionAddress, address(cuteNFT));
        assertEq(lastItem.tokenId, 10);
        assertEq(lastItem.price, 5 ether);
        assertEq(lastItem.seller, user1);
        assertEq(lastItem.isSold, false);

        vm.startPrank(user3);
        DummyERC721(address(booblesNFT)).setApprovalForAll(address(marketplace), true);
        for (uint256 index = 1; index < 6; index++) {
            marketplace.listItem(address(booblesNFT), index, 7 ether);
        }
        vm.stopPrank();

        assertEq(marketplace.itemsCounter(), 15);
        assertEq(DummyERC721(address(booblesNFT)).balanceOf(address(marketplace)), 5);

        lastItem = marketplace.getItem(15);

        assertEq(lastItem.itemId, 15);
        assertEq(lastItem.collectionAddress, address(booblesNFT));
        assertEq(lastItem.tokenId, 5);
        assertEq(lastItem.price, 7 ether);
        assertEq(lastItem.seller, user3);
        assertEq(lastItem.isSold, false);

        vm.startPrank(user2);
        vm.expectRevert("Item not found");
        marketplace.purchase(100);

        vm.expectRevert("Insufficient payment");
        marketplace.purchase(3);

        marketplace.purchase{value: 5 ether}(3);

        vm.expectRevert("Item already sold");
        marketplace.purchase{value: 5 ether}(3);

        assertEq(DummyERC721(address(cuteNFT)).ownerOf(3), address(user2));
        assertEq(address(user1).balance, 105 ether);
        vm.stopPrank();

        vm.startPrank(user1);
        marketplace.purchase{value: 7 ether}(11);
        assertEq(address(user3).balance, 107 ether);
    }
}
