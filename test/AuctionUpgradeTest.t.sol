// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/auction/Auction.sol";
import "../src/auction/AuctionV2.sol";
import "../src/auction/AuctionFactory.sol";
import "../src/chainlink/ChainlinkPriceFeed.sol";
import "../src/nft/MyNFT.sol";

contract AuctionUpgradeTest is Test {
    Auction public auctionProxy;
    AuctionV2 public auctionV2;
    AuctionFactory public factory;
    Auction public auctionImpl;
    ChainlinkPriceFeed public feed;
    MyNFT public nft;

    address constant SELLER = address(0x111);

    function setUp() public {
        feed = new ChainlinkPriceFeed(address(0), address(0));
        auctionImpl = new Auction();
        factory = new AuctionFactory(address(auctionImpl), address(feed));
        nft = new MyNFT();
        auctionV2 = new AuctionV2();

        vm.prank(address(this));
        nft.mint(SELLER);

        vm.prank(SELLER);
        address proxyAddr = factory.createAuctionProxy();
        auctionProxy = Auction(payable(proxyAddr));
    }

    function test_upgrade() public {
        //代理 owner 是工厂，必须以工厂身份调用
        vm.prank(address(factory));
        auctionProxy.upgradeTo(address(auctionV2));

        AuctionV2 upgraded = AuctionV2(payable(address(auctionProxy)));
        assertEq(upgraded.testHello(), "Hello, World!");
    }

    function test_upgrade_revert_unauthorized() public {
        vm.prank(address(0x123));
        vm.expectRevert();
        auctionProxy.upgradeTo(address(auctionV2));
    }
}