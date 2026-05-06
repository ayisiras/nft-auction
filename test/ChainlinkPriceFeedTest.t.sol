// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/chainlink/ChainlinkPriceFeed.sol";

contract ChainlinkPriceFeedTest is Test {
    // 伪造一个可用的喂价地址
    address private constant FEED_ADDR = address(0x123456);
    ChainlinkPriceFeed public feed;

    function setUp() public {
        feed = new ChainlinkPriceFeed(FEED_ADDR, FEED_ADDR);
    }

    // 1. 测试构造函数 & 状态变量
    function test_constructor() public {
        assert(address(feed) != address(0));
    }

    // 2. 测试 getEthPrice（模拟链上返回）
    function test_getEthPrice() public {
        // 模拟 latestRoundData 返回：2000 USD (8位小数)
        vm.mockCall(
            FEED_ADDR,
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(1), int256(2000e8), uint256(1), uint256(1), uint80(1))
        );

        uint256 price = feed.getEthPrice();
        assertEq(price, 2000e8);
    }

    // 3. 测试 getErc20Price
    function test_getErc20Price() public {
        vm.mockCall(
            FEED_ADDR,
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(1), int256(1e8), uint256(1), uint256(1), uint80(1))
        );

        uint256 price = feed.getErc20Price();
        assertEq(price, 1e8);
    }

    // 4. 测试 ETH -> USD 换算
    function test_ethToUsd() public {
        vm.mockCall(
            FEED_ADDR,
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(1), int256(2000e8), uint256(1), uint256(1), uint80(1))
        );

        // 1 ETH = 2000 USD
        uint256 usd = feed.ethToUsd(1 ether);
        assertGt(usd, 0);
    }

    // 5. 测试 ERC20 -> USD 换算
    function test_erc20ToUsd() public {
        vm.mockCall(
            FEED_ADDR,
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(uint80(1), int256(1e8), uint256(1), uint256(1), uint80(1))
        );

        uint256 usd = feed.erc20ToUsd(1 ether);
        assertGt(usd, 0);
    }
}