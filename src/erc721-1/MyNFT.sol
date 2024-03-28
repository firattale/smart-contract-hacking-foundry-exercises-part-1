// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 public totalSupply;
    uint256 public currTokenId;

    constructor() ERC721("EAGLE", "EGL") {}

    function mint() public payable {
        require(totalSupply <= 10000 && msg.value == 0.1 ether);
        currTokenId += 1;
        _mint(msg.sender, currTokenId);
    }
}
