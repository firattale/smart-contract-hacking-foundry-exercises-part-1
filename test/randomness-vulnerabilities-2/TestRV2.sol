// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Game2} from "../../src/randomness-vulnerabilities-2/Game2.sol";
import {Attack} from "../../src/randomness-vulnerabilities-2/Attack.sol";

contract TestRV2 is Test {
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

    function test_Exploit() public {
        uint256 currentBlock = block.number;

        vm.startPrank(attacker);
        attackContract = new Attack(address(gameContract));
        vm.deal(address(attackContract), 10 ether);

        for (uint256 index = 0; index < 5; index++) {
            attackContract.attack();
            vm.roll(currentBlock + 1 + index);
        }

        vm.stopPrank();

        assertEq(address(attacker).balance, INITIAL_POT);
    }
}
