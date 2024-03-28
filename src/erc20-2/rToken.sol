// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract rToken is ERC20 {
    address public owner;
    address public underlyingToken;

    // TODO: Complete this contract functionality

    modifier onlyOwner() {
        require(msg.sender == owner, "RESTRICTED! Only owner can perform this call.");
        _;
    }

    constructor(address _underlyingToken, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        require(_underlyingToken != address(0));
        owner = msg.sender;
        underlyingToken = _underlyingToken;
    }

    function mint(address token, uint256 amount) external onlyOwner {
        _mint(token, amount);
    }

    function burn(address token, uint256 amount) external onlyOwner {
        _burn(token, amount);
    }
}
