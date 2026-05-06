// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../chainlink/ChainlinkPriceFeed.sol";
import "./IAuction.sol";

/**
 * @title 拍卖合约 V1（可升级）
 * @dev 实现拍卖核心逻辑，支持 UUPS 升级、安全 NFT 托管
 */
contract Auction is IAuction, UUPSUpgradeable, OwnableUpgradeable, ERC721Holder {
    /// 拍卖信息
    AuctionInfo public auctionInfo;
    /// 出价历史
    Bid[] public bidHistory;
    /// 是否已创建拍卖
    bool public auctionCreated;
    /// 价格预言机
    ChainlinkPriceFeed public priceFeed;

    /**
     * @dev 构造函数：禁用初始化
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev 代理初始化方法
     * @param _priceFeed 预言机地址
     */
    function initialize(address _priceFeed) external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        priceFeed = ChainlinkPriceFeed(_priceFeed);
    }

    /**
     * @dev 创建拍卖
     * @param _nftContract NFT 合约
     * @param _tokenId NFT ID
     * @param _duration 时长
     * @param _minBid 最低出价
     * @param _erc20Token 支付代币
     */
    function createAuction(
        address _nftContract,
        uint256 _tokenId,
        uint256 _duration,
        uint256 _minBid,
        address _erc20Token
    ) external override {
        require(!auctionCreated, "AUCTION_ALREADY_CREATED");
        IERC721 nft = IERC721(_nftContract);
        require(nft.ownerOf(_tokenId) == msg.sender, "NOT_NFT_OWNER");

        // 安全托管 NFT
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        auctionInfo = AuctionInfo({
            seller: msg.sender,
            nftContract: _nftContract,
            tokenId: _tokenId,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            minBid: _minBid,
            erc20Token: _erc20Token,
            status: AuctionStatus.ACTIVE,
            highestBid: Bid(address(0), 0, 0, false, 0)
        });

        auctionCreated = true;
        emit AuctionCreated(msg.sender, _nftContract, _tokenId, auctionInfo.endTime);
    }

    /**
     * @dev ETH 出价
     */
    function bidEth() external payable override {
        uint256 usdValue = priceFeed.ethToUsd(msg.value);
        _bid(true, msg.value, usdValue);
    }

    /**
     * @dev ERC20 出价
     * @param _amt 出价数量
     */
    function bidErc20(uint256 _amt) external override {
        uint256 usdValue = priceFeed.erc20ToUsd(_amt);
        _bid(false, _amt, usdValue);
    }

    /**
     * @dev 内部出价逻辑
     * @param _isEth 是否 ETH
     * @param _amt 金额
     * @param _usdValue 美元价值
     */
    function _bid(bool _isEth, uint256 _amt, uint256 _usdValue) internal {
        AuctionInfo storage info = auctionInfo;
        require(auctionCreated, "AUCTION_NOT_CREATED");
        require(info.status == AuctionStatus.ACTIVE, "AUCTION_NOT_ACTIVE");
        require(block.timestamp < info.endTime, "AUCTION_ENDED");
        require(_usdValue > info.highestBid.usdValue, "BID_TOO_LOW");

        if (!_isEth) {
            IERC20(info.erc20Token).transferFrom(msg.sender, address(this), _amt);
        }

        info.highestBid = Bid(msg.sender, _amt, block.timestamp, _isEth, _usdValue);
        bidHistory.push(info.highestBid);
        emit BidPlaced(msg.sender, _amt, _isEth, _usdValue);
    }

    /**
     * @dev 结束拍卖
     */
    function endAuction() external override {
        AuctionInfo storage info = auctionInfo;
        require(auctionCreated, "NO_AUCTION");
       require( info.status!=AuctionStatus.ENDED && info.endTime <= block.timestamp,"Auction has not ended");
        IERC721 nft = IERC721(info.nftContract);

        if (info.highestBid.bidder != address(0)) {
            nft.safeTransferFrom(address(this), info.highestBid.bidder, info.tokenId);
        } else {
            nft.safeTransferFrom(address(this), info.seller, info.tokenId);
        }

        info.status = AuctionStatus.ENDED;
        emit AuctionEnded(info.highestBid.bidder, info.highestBid.amount);
    }

    /**
     * @dev 升级权限校验
     * @param 新实现地址
     */
    function _authorizeUpgrade(address) internal override onlyOwner {}

    receive() external payable {}
}