import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";


describe("NFT contract", function () {

  async function deployTokenFixture() {
    // Get the ContractFactory and Signers here.
    const NFTContract = await ethers.getContractFactory("NFT");
    const MarketplaceContract = await ethers.getContractFactory("NFTMarketplace");
    const [owner, addr1, addr2,addr3] = await ethers.getSigners();

    const Marketplace = await MarketplaceContract.deploy();

    await Marketplace.deployed();

    const NFT = await NFTContract.deploy(Marketplace.address);

    await NFT.deployed();


    return { NFTContract, NFT, owner, addr1, addr2 ,addr3, Marketplace};
  }

  describe("NFT", function () {
    it("Should mint NFT", async function () {

      const { NFT, addr1 } = await loadFixture(deployTokenFixture);

      await NFT.mintNFT(addr1.address)

    });

  });

  describe("Marketplace", function () {
    it("Should list & delist NFT", async function () {

      const { NFTContract,NFT, owner, addr1, Marketplace } = await loadFixture(deployTokenFixture);

      await NFT.mintNFT(addr1.address);

      expect(await NFT.balanceOf(addr1.address)).to.equal(1);

      // address 1 approval for marketplace
      await NFT.connect(addr1).approve(Marketplace.address,1)

      // address 1 list NFT
      await Marketplace.connect(addr1).listNft(NFT.address, 1, ethers.utils.parseEther("0.1"))

      expect(await NFT.ownerOf(1)).to.equal(Marketplace.address);

       // address 1 delist NFT
      await Marketplace.connect(addr1).delistNft(0)

      expect(await NFT.ownerOf(1)).to.equal(addr1.address);

    });

    it("Should change price NFT", async function () {

      const { NFTContract,NFT, owner, addr1, Marketplace } = await loadFixture(deployTokenFixture);

      await NFT.mintNFT(addr1.address);

      expect(await NFT.balanceOf(addr1.address)).to.equal(1);

      // address 1 approval for marketplace
      await NFT.connect(addr1).approve(Marketplace.address,1)

      // address 1 list NFT
      await Marketplace.connect(addr1).listNft(NFT.address, 1, ethers.utils.parseEther("0.1"))

      // change 1 list NFT
      await Marketplace.connect(addr1).changePrice(0,ethers.utils.parseEther("0.2"))

      expect(await Marketplace.getPrice(0)).to.equal(ethers.utils.parseEther("0.2"));

    });

    it("Should buy NFT", async function () {

      const { NFTContract,NFT, owner, addr1,addr2,addr3, Marketplace } = await loadFixture(deployTokenFixture);

      await NFT.mintNFT(addr1.address);

      expect(await NFT.balanceOf(addr1.address)).to.equal(1);

      // address 1 approval for marketplace
      await NFT.connect(addr1).approve(Marketplace.address,1)

      // address 1 list NFT
      await Marketplace.connect(addr1).listNft(NFT.address, 1, ethers.utils.parseEther("0.3"))

      // addr2 buy nft addr1
      await Marketplace.connect(addr2).buyNft(0, {value: ethers.utils.parseEther("0.3")})

      // check ownerOf item 1
      expect(await NFT.ownerOf(1)).to.equal(addr2.address);

      // check isSold NFT
       expect(await Marketplace.getIsSold(0)).to.equal(true);

       // addr3 buy nft addr1
      Marketplace.connect(addr3).buyNft(0, {value: ethers.utils.parseEther("0.3")})
      .catch(() =>{})
      .then((item) => {throw Error("Should not be able to buy sold NFT")})

      // address 2 list NFT again
      await NFT.connect(addr2).approve(Marketplace.address, 1)

      await Marketplace.connect(addr2).listNft(NFT.address, 1, ethers.utils.parseEther("0.5"))

      // addr2 not buy nft addr1
      Marketplace.connect(addr2).buyNft(1, {value: ethers.utils.parseEther("0.5")})
      // .catch(() =>{})
      // .then((item) => {throw Error("Should not be able to buy this NFT")})
    });

  });

});
