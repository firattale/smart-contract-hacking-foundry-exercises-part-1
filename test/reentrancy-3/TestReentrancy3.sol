//  SPDX-License-Identifier: GPL-3.0-or-later
//   SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
//   https:smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {ChainLend} from "../../src/reentrancy-3/ChainLend.sol";
import {AttackChainLend} from "../../src/reentrancy-3/AttackChainLend.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev
 * run
 *  export ETH_RPC_URL=https://eth.llamarpc.com
 *  forge test --fork-url $ETH_RPC_URL --fork-block-number 15969633 --match-contract TestReentrancy3
 */
contract TestReentrancy3 is Test {
    address deployer;
    address attacker;
    AttackChainLend attackChainLend;

    address constant imBTC_ADDRESS = 0x3212b29E33587A00FB1C83346f5dBFA69A458923;
    address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant imBTC_WHALE = 0xFEa4224Da399F672eB21a9F3F7324cEF1d7a965C;
    address constant USDC_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

    uint256 constant USDC_IN_CHAINLEND = 1_000_000 * 1e6;
    uint256 constant ONE_IMBTC = 1 * 1e8;

    ChainLend chainLend;
    IERC20 imBTC;
    IERC20 usdc;

    function setUp() public {
        deployer = makeAddr("deployer");
        attacker = makeAddr("attacker");

        vm.deal(deployer, 100 ether);
        vm.deal(attacker, 100 ether);

        imBTC = IERC20(imBTC_ADDRESS);
        usdc = IERC20(USDC_ADDRESS);

        vm.prank(deployer);
        chainLend = new ChainLend(imBTC_ADDRESS, USDC_ADDRESS);

        vm.prank(imBTC_WHALE);
        imBTC.transfer(attacker, ONE_IMBTC);

        assertEq(imBTC.balanceOf(attacker), ONE_IMBTC);

        vm.prank(USDC_WHALE);
        usdc.transfer(address(chainLend), USDC_IN_CHAINLEND);

        assertEq(usdc.balanceOf(address(chainLend)), USDC_IN_CHAINLEND);
    }

    function test_Hack() public {
        vm.startPrank(attacker);

        attackChainLend = new AttackChainLend(imBTC_ADDRESS, USDC_ADDRESS, address(chainLend));
        imBTC.transfer(address(attackChainLend), ONE_IMBTC);

        assertEq(imBTC.balanceOf(address(attackChainLend)), ONE_IMBTC);

        attackChainLend.attack();

        vm.stopPrank();

        assertEq(usdc.balanceOf(attacker), USDC_IN_CHAINLEND);
        assertEq(imBTC.balanceOf(attacker), ONE_IMBTC);
    }
}
