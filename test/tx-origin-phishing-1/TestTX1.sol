// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {SimpleSmartWallet} from "../../src/tx-origin-phishing-1/SimpleSmartWallet.sol";
import {Charity} from "../../src/tx-origin-phishing-1/Charity.sol";

contract TestTX1 is Test {
    address fundManager;
    address hacker;
    SimpleSmartWallet simpleSmartWallet;
    Charity charity;

    uint256 constant HEDGE_FUND_DEPOSIT = 2800 ether;
    uint256 constant CHARITY_DONATION = 0.1 ether;

    function setUp() public {
        fundManager = makeAddr("fundManager");
        hacker = makeAddr("hacker");

        vm.deal(fundManager, HEDGE_FUND_DEPOSIT + CHARITY_DONATION);

        vm.prank(fundManager);

        simpleSmartWallet = new SimpleSmartWallet{value: HEDGE_FUND_DEPOSIT}();
        assertEq(address(simpleSmartWallet).balance, HEDGE_FUND_DEPOSIT);

        vm.prank(hacker);
        charity = new Charity(address(simpleSmartWallet), hacker);
    }

    function test_Hack() public {
        vm.prank(fundManager, fundManager);

        (bool sent,) = address(charity).call{value: CHARITY_DONATION}("");
        require(sent, "Transfer Failed!");

        assertEq(hacker.balance, HEDGE_FUND_DEPOSIT);
    }
}
