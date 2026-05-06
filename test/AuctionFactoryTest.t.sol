// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/auction/AuctionFactory.sol";
import "../src/auction/Auction.sol";
import "../src/chainlink/ChainlinkPriceFeed.sol";
import "../src/nft/MyNFT.sol";

/**
 * @title 拍卖工厂测试
 * @dev 测试代理创建、初始化、权限流程
 * @notice 无 NOT_NFT_OWNER 错误
 */
contract AuctionFactoryTest is Test {
    AuctionFactory public factory;
    Auction public auctionImpl;
    ChainlinkPriceFeed public feed;
    MyNFT public nft;

    address constant SELLER = address(0x111);

    function setUp() public {
        address ethUsd = vm.envAddress("ETH_USD_FEED");
        address erc20Usd = vm.envAddress("ERC20_USD_FEED");

        feed = new ChainlinkPriceFeed(ethUsd, erc20Usd);
        auctionImpl = new Auction();
        factory = new AuctionFactory(address(auctionImpl), address(feed));
        nft = new MyNFT();

        // 铸造NFT给卖家
        vm.prank(address(this));
        nft.mint(SELLER);
    }

    /**
     * @dev 测试创建拍卖代理 + 卖家初始化拍卖
     */
    function test_CreateAuctionFromFactory() public {
        // 卖家创建代理
        vm.prank(SELLER);
        address auctionAddr = factory.createAuctionProxy();
        Auction auction = Auction(payable(auctionAddr));

        // 卖家授权代理
        vm.prank(SELLER);
        nft.setApprovalForAll(auctionAddr, true);

        // 卖家自己创建拍卖（✅ 权限正确）
        vm.prank(SELLER);
        auction.createAuction(address(nft), 0, 1 days, 0.1 ether, address(0));

        assertTrue(auction.auctionCreated());
    }
}