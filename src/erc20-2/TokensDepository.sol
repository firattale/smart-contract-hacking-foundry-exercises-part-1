// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {rToken} from "./rToken.sol";

/**
 * @title TokensDepository
 * @author FiratStory (firatstory.eth)
 */
contract TokensDepository {
    mapping(address tokenAddress => rToken rToken) public rTokens;

    event Deposit(address indexed tokenAddress, address indexed user, uint256 amount);
    event Withdraw(address indexed tokenAddress, address indexed user, uint256 amount);

    modifier validToken(address tokenAddress) {
        require(rTokens[tokenAddress] != rToken(address(0)), "Invalid token address");
        _;
    }

    constructor(address _aave, address _uni, address _weth) {
        rTokens[_aave] = new rToken(_aave, "AAVE RToken", "rAAVE");
        rTokens[_uni] = new rToken(_uni, "UNI RToken", "rUNI");
        rTokens[_weth] = new rToken(_weth, "WETH RToken", "rWETH");
    }

    function deposit(address tokenAddress, uint256 amount) external validToken(tokenAddress) {
        bool success = IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        rTokens[tokenAddress].mint(msg.sender, amount);

        emit Deposit(tokenAddress, msg.sender, amount);
    }

    function withdraw(address tokenAddress, uint256 amount) external validToken(tokenAddress) {
        bool success = IERC20(tokenAddress).transfer(msg.sender, amount);
        require(success, "Transfer failed");

        rTokens[tokenAddress].burn(msg.sender, amount);

        emit Withdraw(tokenAddress, msg.sender, amount);
    }
}
