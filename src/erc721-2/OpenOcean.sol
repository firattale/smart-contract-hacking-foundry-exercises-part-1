// SPDX-License-Identifier: GPL-3.0-or-later
// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title OpenOcean
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract OpenOcean {
    // TODO: Complete this contract functionality

    // TODO: Constants
    uint256 public constant MAX_PRICE = 100 ether;

    // TODO: Item Struct
    struct Item {
        uint256 itemId;
        address collectionContract;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool isSold;
    }

    // TODO: State Variables and Mappings
    uint256 public itemsCounter;
    mapping(uint256 => Item) public listedItems;

    constructor() {}

    // TODO: List item function
    function listItem(address _collection, uint256 _tokenId, uint256 _price) external {
        // 1. Make sure params are correct
        require(_price > 0 && _price <= MAX_PRICE, "0<=Price<=100 ETH");
        // 2. Increment itemsCounter
        itemsCounter += 1;
        // 3. Transfer token from sender to the contract
        IERC721(_collection).transferFrom(msg.sender, address(this), _tokenId);
        // 4. Add item to listedItems mapping
        listedItems[itemsCounter].itemId = itemsCounter;
        listedItems[itemsCounter].collectionContract = _collection;
        listedItems[itemsCounter].tokenId = _tokenId;
        listedItems[itemsCounter].price = _price;
        listedItems[itemsCounter].seller = payable(msg.sender);
        listedItems[itemsCounter].isSold = false;
    }

    // TODO: Purchase item function

    function purchase(uint _itemId) external payable {
        // 1. Check that item exists and not sold
        require(listedItems[_itemId].itemId != 0, "incorrect _itemId");
        require(listedItems[_itemId].isSold == false, "Item Already Sold");
        // 2. Check that enough ETH was paid
        require(listedItems[_itemId].price == msg.value, "Not Enough ETH");
        // 3. Change item status to "sold"
        listedItems[_itemId].isSold = true;
        // 4. Transfer NFT to buyer
        IERC721(listedItems[_itemId].collectionContract).transferFrom(
            address(this),
            msg.sender,
            listedItems[_itemId].tokenId
        );
        // 5. Transfer ETH to seller
        (bool success, ) = listedItems[_itemId].seller.call{value: msg.value}("");
        require(success, "Transfer of ETH Failed!!!");
    }
}
