// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./GameItems.sol";

 contract CryptoEmpireToken is ERC1155, Ownable {
    //NftId public nftId;
    constructor() ERC1155("someuri") Ownable(msg.sender) {}

    function setURI(string memory _newuri) public onlyOwner {
        _setURI(_newuri);
    }

    function mint(address _account, uint256 _amount, NftId _id) public onlyOwner {
        _mint(_account, uint256(_id), _amount, "");
    }
}
