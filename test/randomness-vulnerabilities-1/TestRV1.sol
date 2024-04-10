// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Game} from "../../src/randomness-vulnerabilities-1/Game.sol";
import {Attack} from "../../src/randomness-vulnerabilities-1/Attack.sol";

contract TestRV1 is Test {
    address deployer;
    address attacker;
    Game gameContract;
    Attack attackContract;

    uint256 constant GAME_POT = 10 ether;

    function setUp() public {
        deployer = makeAddr("deployer");
        attacker = makeAddr("attacker");

        vm.deal(deployer, 20 ether);

        vm.startPrank(deployer);
        gameContract = new Game{value: GAME_POT}();
        vm.stopPrank();

        assertEq(address(gameContract).balance, GAME_POT);
    }

    function test_Exploit() public {
        vm.startPrank(attacker);
        attackContract = new Attack(address(gameContract));
        attackContract.attack();
        vm.stopPrank();

        assertEq(address(attacker).balance, GAME_POT);
    }
}
