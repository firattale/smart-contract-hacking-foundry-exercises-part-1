// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title SimpleToken
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract SimpleTokenFixed {
    address public minter;
    mapping(address => uint256) public getBalance;
    uint256 public totalSupply;

    constructor() {
        minter = msg.sender;
    }

    function mint(address _to, uint256 _amount) external {
        require(msg.sender == minter, "not minter");
        getBalance[_to] += _amount;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(getBalance[msg.sender] - _value >= 0);
        getBalance[msg.sender] -= _value;
        getBalance[_to] += _value;
        return true;
    }
}
