// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {rToken} from "./rToken.sol";

/**
 * @title TokensDepository
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract TokensDepository {
    mapping(address => IERC20) public tokens;
    mapping(address => rToken) public rTokens;

    error depositFailed();
    error withdrawFailed();

    modifier validToken(address token) {
        require(token != address(0));
        _;
    }

    constructor(address _aave, address _uni, address _weth) {
        tokens[_aave] = IERC20(_aave);
        tokens[_uni] = IERC20(_uni);
        tokens[_weth] = IERC20(_weth);

        rTokens[_aave] = new rToken(_aave, "Receipt AAVE", "rAAVE");
        rTokens[_uni] = new rToken(_uni, "Receipt UNI", "rUNI");
        rTokens[_weth] = new rToken(_weth, "Receipt WETH", "rWETH");
    }

    function deposit(address token, uint256 amount) public validToken(token) {
        bool success = tokens[token].transferFrom(msg.sender, address(this), amount);
        //require(success, "Transfer Failed!!!");
        if (!success) {
            revert depositFailed();
        }
        rTokens[token].mint(msg.sender, amount);
    }

    function withdraw(address token, uint256 amount) public validToken(token) {
        rTokens[token].burn(msg.sender, amount);

        bool success = tokens[token].transfer(msg.sender, amount);
        //require(success, "Transfer Failed!!!");
        if (!success) {
            revert withdrawFailed();
        }
    }
}
