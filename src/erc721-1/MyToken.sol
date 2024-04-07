// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyToken is ERC721 {
    uint256 constant MAX_SUPPLY = 10000;
    uint256 public tokenCounter;

    constructor() ERC721("Fenerbahce Token", "FB") {}

    function mint() public payable {
        require(msg.value == 0.1 ether, "You must send 1 ether to mint a token");
        require(tokenCounter < MAX_SUPPLY, "Max supply reached");
        tokenCounter++;
        _mint(_msgSender(), tokenCounter);
    }
}
