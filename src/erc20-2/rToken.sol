// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract rToken is ERC20, Ownable {
    address _underlyingToken;

    constructor(address underlyingToken) ERC20("rToken", "rToken") Ownable(msg.sender) {
        require(underlyingToken != address(0));
        _underlyingToken = underlyingToken;
    }

    function mint(address _to, uint256 amount) public onlyOwner {
        _mint(_to, amount);
    }

    function burn(address _from, uint256 amount) public onlyOwner {
        _burn(_from, amount);
    }
}
