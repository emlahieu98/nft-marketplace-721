// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;

    event listNftEvent(
        address indexed seller,
        address nftAddress,
        uint256 tokenId,
        uint256 price
    );
    event buyNftEvent(
        address indexed seller,
        address indexed buyer,
        address nftAddress,
        uint256 tokenId,
        uint256 price
    );

    struct NFTItem {
        address nftContract;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        bool isSold;
    }

    NFTItem[] public nftItems;
    Counters.Counter private _itemIds;

    function listNft(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) public nonReentrant returns (uint256) {
        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);
        nftItems.push(
            NFTItem(nftAddress, tokenId, payable(msg.sender), price, false)
        );
        emit listNftEvent(msg.sender, nftAddress, tokenId, price);
        return itemId;
    }

    function delistNft(uint256 _itemId) public {
        NFTItem storage item = nftItems[_itemId];
        require(msg.sender == item.seller, "Only seller can delist NFT items");
        require(!item.isSold, "Item is already sold");
        IERC721(item.nftContract).transferFrom(
            address(this),
            msg.sender,
            item.tokenId
        );
        delete nftItems[_itemId];
    }

    function changePrice(uint256 _itemId, uint256 _amount) public {
        NFTItem storage item = nftItems[_itemId];
        require(msg.sender == item.seller, "Only seller can delist NFT items");
        require(!item.isSold, "Item is already sold");
        item.price = _amount;
    }

    function getPrice(uint256 _itemId) public view returns (uint256) {
        NFTItem storage item = nftItems[_itemId];
        return item.price;
    }

    function getIsSold(uint256 _itemId) public view returns (bool) {
        return nftItems[_itemId].isSold;
    }

    function buyNft(uint256 _itemId) public payable nonReentrant {
        NFTItem storage item = nftItems[_itemId];
        require(msg.value == item.price, "Price is not correct");
        require(msg.sender != item.seller, "Owner cannot buy this nft ");
        require(!item.isSold, "Item is already sold");
        emit buyNftEvent(
            item.seller,
            msg.sender,
            item.nftContract,
            item.tokenId,
            item.price
        );
        IERC721(item.nftContract).transferFrom(
            address(this),
            msg.sender,
            item.tokenId
        );
        item.seller.transfer(msg.value);
        item.isSold = true;
    }
}
