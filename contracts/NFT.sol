// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address public nftMarketplace;

    constructor(address _nftMarketplace) public ERC721("NFT", "SVG") {
        nftMarketplace = _nftMarketplace;
    }

    function mintNFT(address to) public returns (uint256) {
        _tokenIds.increment();

        string
            memory tokenURI = "https://k53v2khqb3hmylhakkkkfuvhc6z5ltou2rom6er6bpqfyhzyfd5a.arweave.net/V3ddKPAOzsws4FKUotKnF7PVzdTUXM8SPgvgXB84KPo";

        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(nftMarketplace, true);

        console.log("Mint NFT ", newItemId, to);

        return newItemId;
    }
}
