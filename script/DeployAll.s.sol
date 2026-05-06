// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "forge-std/Script.sol";
import "../src/auction/Auction.sol";
import "../src/auction/AuctionFactory.sol";
import "../src/chainlink/ChainlinkPriceFeed.sol";
import "../src/nft/MyNFT.sol";
import "../src/token/TestERC20.sol";

/**
 * @title 全量部署脚本
 * @dev 部署所有合约：预言机 → 拍卖实现 → 工厂 → NFT → ERC20
 */
contract DeployAll is Script {
    function run() external {
        // 从环境变量读取配置
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address ethUsd = vm.envAddress("ETH_USD_FEED");
        address erc20Usd = vm.envAddress("ERC20_USD_FEED");

        vm.startBroadcast(privateKey);

        // 1. 部署预言机
        ChainlinkPriceFeed feed = new ChainlinkPriceFeed(ethUsd, erc20Usd);
        // 2. 部署拍卖 V1
        Auction auctionImpl = new Auction();
              console.log("auctionImpl deployed to:", address(auctionImpl));
        // 3. 部署工厂
        AuctionFactory factory = new AuctionFactory(address(auctionImpl), address(feed));
         console.log("factory deployed to:", address(factory));
        // 4. 部署测试 NFT
        MyNFT nft = new MyNFT();
         console.log("nft deployed to:", address(nft));
        // 5. 部署测试 ERC20
        TestERC20 tusd = new TestERC20();
       

        vm.stopBroadcast();
    }
}