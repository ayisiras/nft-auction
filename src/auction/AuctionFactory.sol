// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./Auction.sol";

/**
 * @title 拍卖工厂合约
 */
contract AuctionFactory {
    address public auctionImpl;
    address public priceFeed;

    event AuctionCreated(address indexed auction, address seller);

    constructor(address _impl, address _priceFeed) {
        auctionImpl = _impl;
        priceFeed = _priceFeed;
    }

    /**
     * @dev 创建代理 + 初始化
     * @return 代理地址
     */
    function createAuctionProxy() external returns (address) {
        ERC1967Proxy proxy = new ERC1967Proxy(auctionImpl, "");
        Auction auc = Auction(payable(address(proxy)));
        auc.initialize(priceFeed);

        emit AuctionCreated(address(proxy), msg.sender);
        return address(proxy);
    }
}