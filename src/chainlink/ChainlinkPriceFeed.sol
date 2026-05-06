// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title Chainlink 价格预言机
 * @dev 提供 ETH/USD 和 ERC20/USD 实时价格转换
 * @notice 全注释 + 无报错 + 可直接调用
 */
contract ChainlinkPriceFeed {
    /// @notice ETH 对 USD 价格预言机
    AggregatorV3Interface public immutable ethUsd;

    /// @notice ERC20 对 USD 价格预言机
    AggregatorV3Interface public immutable erc20Usd;

    /**
     * @dev 构造函数：初始化预言机地址
     * @param _ethUsd ETH/USD 预言机地址
     * @param _erc20Usd ERC20/USD 预言机地址
     */
    constructor(address _ethUsd, address _erc20Usd) {
        ethUsd = AggregatorV3Interface(_ethUsd);
        erc20Usd = AggregatorV3Interface(_erc20Usd);
    }

    /**
     * @dev 获取 ETH 美元价格
     * @return 美元价格（8位小数）
     */
    function getEthPrice() public view returns (uint256) {
        (, int256 price, , , ) = ethUsd.latestRoundData();
        return uint256(price);
    }

    /**
     * @dev 获取 ERC20 美元价格
     * @return 美元价格（8位小数）
     */
    function getErc20Price() public view returns (uint256) {
        (, int256 price, , , ) = erc20Usd.latestRoundData();
        return uint256(price);
    }

    /**
     * @dev 将 ETH 数量转换为美元价值
     * @param ethAmount ETH 数量 (wei)
     * @return 美元价值
     */
    function ethToUsd(uint256 ethAmount) external view returns (uint256) {
        return (ethAmount * getEthPrice()) / 1e18;
    }

    /**
     * @dev 将 ERC20 数量转换为美元价值
     * @param erc20Amount ERC20 数量
     * @return 美元价值
     */
    function erc20ToUsd(uint256 erc20Amount) external view returns (uint256) {
        return (erc20Amount * getErc20Price()) / 1e18;
    }
}