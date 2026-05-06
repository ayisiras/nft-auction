// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./Auction.sol";

/**
 * @title AuctionV2
 * @dev 拍卖合约 V2，新增 testHello 方法
 */
contract AuctionV2 is Auction {
    /**
     * @dev 新增测试方法
     * @return "Hello, World!"
     */
    function testHello() public pure returns (string memory) {
        return "Hello, World!";
    }
}