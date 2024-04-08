// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {Game2} from "../../src/randomness-vulnerabilities-2/Game2.sol";
import {Attack} from "../../src/randomness-vulnerabilities-1/Attack.sol";

contract TestRandomness2 is Test {
    address deployer;
    address attacker;
    Game2 gameContract;
    Attack attackContract;

    uint256 constant INITIAL_POT = 20 ether;

    function setUp() public {
        deployer = makeAddr("deployer");
        attacker = makeAddr("attacker");

        vm.deal(deployer, 20 ether);

        vm.startPrank(deployer);
        gameContract = new Game2{value: INITIAL_POT}();
        vm.stopPrank();

        assertEq(address(gameContract).balance, INITIAL_POT);
    }

    function test_Exploit() public {}
}
