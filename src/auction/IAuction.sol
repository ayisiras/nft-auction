// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title 拍卖合约接口
 * @dev 定义拍卖系统所有规范、结构体、事件、外部方法
 */
interface IAuction {
    /**
     * @dev 拍卖状态枚举
     * @param CREATED 已创建
     * @param ACTIVE 拍卖中
     * @param ENDED 已结束
     * @param CANCELLED 已取消（无出价）
     */
    enum AuctionStatus {
        CREATED,
        ACTIVE,
        ENDED,
        CANCELLED
    }

    /**
     * @dev 出价结构体
     * @param bidder 出价人地址
     * @param amount 出价金额
     * @param timestamp 出价时间
     * @param isEth 是否使用 ETH 出价
     * @param usdValue 美元价值（Chainlink 换算）
     */
    struct Bid {
        address bidder;
        uint256 amount;
        uint256 timestamp;
        bool isEth;
        uint256 usdValue;
    }

    /**
     * @dev 拍卖信息结构体
     * @param seller 卖家
     * @param nftContract NFT 合约地址
     * @param tokenId NFT ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param minBid 最低出价
     * @param erc20Token 支持的支付代币
     * @param status 拍卖状态
     * @param highestBid 最高出价
     */
    struct AuctionInfo {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        uint256 minBid;
        address erc20Token;
        AuctionStatus status;
        Bid highestBid;
    }

    // 拍卖创建成功事件
    event AuctionCreated(address seller, address nft, uint256 tokenId, uint256 endTime);
    // 新出价事件
    event BidPlaced(address bidder, uint256 amount, bool isEth, uint256 usdValue);
    // 拍卖结束事件
    event AuctionEnded(address winner, uint256 amount);

    /**
     * @dev 创建拍卖
     * @param _nftContract NFT 合约地址
     * @param _tokenId 拍卖的 NFT ID
     * @param _duration 拍卖时长
     * @param _minBid 最低出价
     * @param _erc20Token 支付代币地址
     */
    function createAuction(
        address _nftContract,
        uint256 _tokenId,
        uint256 _duration,
        uint256 _minBid,
        address _erc20Token
    ) external;

    /**
     * @dev 使用 ETH 出价
     */
    function bidEth() external payable;

    /**
     * @dev 使用 ERC20 代币出价
     * @param _amt 出价数量
     */
    function bidErc20(uint256 _amt) external;

    /**
     * @dev 结束拍卖并结算
     */
    function endAuction() external;
}