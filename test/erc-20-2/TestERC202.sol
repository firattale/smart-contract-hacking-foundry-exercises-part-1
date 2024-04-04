// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TokensDepository} from "../../src/erc20-2/TokensDepository.sol";
/**
 * @dev run "forge test --fork-url $ETH_RPC_URL --fork-block-number 15969633 --match-contract ERC202"
 */

contract TestERC202 is Test {
    address constant AAVE_ADDRESS = address(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
    address constant UNI_ADDRESS = address(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address constant AAVE_HOLDER = address(0x2eFB50e952580f4ff32D8d2122853432bbF2E204);
    address constant UNI_HOLDER = address(0x193cEd5710223558cd37100165fAe3Fa4dfCDC14);
    address constant WETH_HOLDER = address(0x741AA7CFB2c7bF2A1E7D4dA2e3Df6a56cA4131F3);

    uint256 constant ONE_ETH = 1 ether;

    TokensDepository tokensDepository;

    address deployer;
    address aaveHolder;
    address uniHolder;
    address wethHolder;

    address rAAVE;
    address rUNI;
    address rWETH;

    uint256 initialAAVEBalance;
    uint256 initialUNIBalance;
    uint256 initialWETHBalance;

    function setUp() public {
        deployer = address(1);

        // Load holders (accounts which hold tokens on Mainnet)
        aaveHolder = address(0x2eFB50e952580f4ff32D8d2122853432bbF2E204);
        uniHolder = address(0x193cEd5710223558cd37100165fAe3Fa4dfCDC14);
        wethHolder = address(0x741AA7CFB2c7bF2A1E7D4dA2e3Df6a56cA4131F3);

        // Send some ETH to tokens holders
        vm.deal(aaveHolder, ONE_ETH);
        vm.deal(uniHolder, ONE_ETH);
        vm.deal(wethHolder, ONE_ETH);

        initialAAVEBalance = IERC20(AAVE_ADDRESS).balanceOf(aaveHolder);
        initialUNIBalance = IERC20(UNI_ADDRESS).balanceOf(uniHolder);
        initialWETHBalance = IERC20(WETH_ADDRESS).balanceOf(wethHolder);

        tokensDepository = new TokensDepository(AAVE_ADDRESS, UNI_ADDRESS, WETH_ADDRESS);

        rAAVE = address(tokensDepository.rTokens(AAVE_ADDRESS));
        rUNI = address(tokensDepository.rTokens(UNI_ADDRESS));
        rWETH = address(tokensDepository.rTokens(WETH_ADDRESS));

        console.log("initialAAVEBalance: %s", initialAAVEBalance);
        console.log("initialUNIBalance: %s", initialUNIBalance);
        console.log("initialWETHBalance: %s", initialWETHBalance);
    }

    function test_Deposit_and_Withdraw() public {
        console.log("Testing Deposits...");
        // Deposit
        vm.startPrank(aaveHolder);
        IERC20(AAVE_ADDRESS).approve(address(tokensDepository), 15 * 1e18);
        tokensDepository.deposit(AAVE_ADDRESS, 15 * 1e18);
        vm.stopPrank();

        vm.startPrank(uniHolder);
        IERC20(UNI_ADDRESS).approve(address(tokensDepository), 5231 * 1e18);
        tokensDepository.deposit(UNI_ADDRESS, 5231 * 1e18);
        vm.stopPrank();

        vm.startPrank(wethHolder);
        IERC20(WETH_ADDRESS).approve(address(tokensDepository), 33 * 1e18);
        tokensDepository.deposit(WETH_ADDRESS, 33 * 1e18);
        vm.stopPrank();

        // Check that the tokens were sucessfuly transfered to the depository
        assertEq(IERC20(AAVE_ADDRESS).balanceOf(address(tokensDepository)), 15 * 1e18);
        assertEq(IERC20(UNI_ADDRESS).balanceOf(address(tokensDepository)), 5231 * 1e18);
        assertEq(IERC20(WETH_ADDRESS).balanceOf(address(tokensDepository)), 33 * 1e18);

        // Check that rTokens were successfully transfered to the aaveHolder
        assertEq(IERC20(rAAVE).balanceOf(aaveHolder), 15 * 1e18);
        assertEq(IERC20(rUNI).balanceOf(uniHolder), 5231 * 1e18);
        assertEq(IERC20(rWETH).balanceOf(wethHolder), 33 * 1e18);

        // Withdraw
        console.log("Testing Withdraw...");

        vm.startPrank(aaveHolder);
        tokensDepository.withdraw(AAVE_ADDRESS, 15 * 1e18);
        vm.stopPrank();

        vm.startPrank(uniHolder);
        tokensDepository.withdraw(UNI_ADDRESS, 5231 * 1e18);
        vm.stopPrank();

        vm.startPrank(wethHolder);
        tokensDepository.withdraw(WETH_ADDRESS, 33 * 1e18);
        vm.stopPrank();

        // Check that the tokens were sucessfuly transfered to the aaveHolder
        assertEq(IERC20(AAVE_ADDRESS).balanceOf(aaveHolder), initialAAVEBalance);
        assertEq(IERC20(UNI_ADDRESS).balanceOf(uniHolder), initialUNIBalance);
        assertEq(IERC20(WETH_ADDRESS).balanceOf(wethHolder), initialWETHBalance);

        // Check that rTokens were burned
        assertEq(IERC20(rAAVE).balanceOf(aaveHolder), 0);
        assertEq(IERC20(rUNI).balanceOf(uniHolder), 0);
        assertEq(IERC20(rWETH).balanceOf(wethHolder), 0);
    }
}
