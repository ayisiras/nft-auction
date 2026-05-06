// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/auction/Auction.sol";
import "../src/auction/AuctionV2.sol";

/**
 * @title 拍卖合约升级脚本
 * @dev 将拍卖代理合约从 V1 升级到 V2
 * @notice 必须由合约所有者执行
 */
contract UpgradeAuction is Script {
    /**
     * @dev 要升级的拍卖代理地址
     */
    address public constant AUCTION_PROXY = 0x1234567890123456789012345678901234567890;

    /**
     * @dev 脚本主函数
     */
    function run() external {
        // 从环境变量获取私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // 部署新版本合约
        AuctionV2 auctionV2 = new AuctionV2();

        // 执行升级（修复 payable 类型转换）
        Auction(payable(AUCTION_PROXY)).upgradeTo(address(auctionV2));

        vm.stopBroadcast();
    }
}