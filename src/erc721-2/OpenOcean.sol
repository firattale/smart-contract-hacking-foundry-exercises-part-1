// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract OpenOcean {
    uint256 constant maxPrice = 100 ether;

    struct Item {
        uint256 itemId;
        address collectionAddress;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool isSold;
    }

    uint256 public itemsCounter;
    mapping(uint256 itemId => Item) public listedItems;

    /**
     * @dev Lists an item on the marketplace.
     * @param _collectionAddress The address of the NFT collection.
     * @param _tokenId The token ID of the NFT to list.
     * @param _price The price of the NFT.
     * Requirements:
     * - `_collectionAddress` cannot be the zero address.
     * - `_price` must be greater than 0 and less than or equal to `maxPrice`.
     * Emits a transfer event when the NFT is transferred from the seller to the contract.
     */
    function listItem(address _collectionAddress, uint256 _tokenId, uint256 _price) external {
        require(_collectionAddress != address(0), "Invalid collection address");
        require(_price > 0 && _price <= maxPrice, "Invalid price");

        itemsCounter += 1;
        IERC721(_collectionAddress).transferFrom(msg.sender, address(this), _tokenId);
        listedItems[itemsCounter] = Item(itemsCounter, _collectionAddress, _tokenId, _price, payable(msg.sender), false);
    }

    /**
     * @dev Allows a user to purchase a listed item from the marketplace.
     * @param _itemId The ID of the item to purchase.
     * Requirements:
     * - The item must exist (itemId must be valid).
     * - The item must not already be sold.
     * - The sent value (msg.value) must exactly match the item's price.
     * On success, the item is marked as sold, the NFT is transferred to the buyer,
     * and the sale proceeds are transferred to the seller.
     */
    function purchase(uint256 _itemId) external payable {
        require(listedItems[_itemId].itemId == _itemId, "Item not found");
        require(listedItems[_itemId].isSold == false, "Item already sold");
        require(msg.value == listedItems[_itemId].price, "Insufficient payment");

        listedItems[_itemId].isSold = true;

        IERC721(listedItems[_itemId].collectionAddress).transferFrom(
            address(this), msg.sender, listedItems[_itemId].tokenId
        );

        (bool success,) = listedItems[_itemId].seller.call{value: msg.value}("");
        require(success, "Transfer failed");
    }

    function getItem(uint256 _itemId) external view returns (Item memory) {
        return listedItems[_itemId];
    }
}
