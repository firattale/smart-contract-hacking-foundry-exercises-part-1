// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

/**
 * @title SimpleToken
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract SimpleToken {
    address public minter;
    mapping(address => uint) public getBalance;
    uint public totalSupply;

    constructor() {
        minter = msg.sender;
    }

    function mint(address _to, uint _amount) external {
        require(msg.sender == minter, "not minter");
        getBalance[_to] += _amount;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        require(getBalance[msg.sender] - _value >= 0);
        getBalance[msg.sender] -= _value;
        getBalance[_to] += _value;
        return true;
    }
}
