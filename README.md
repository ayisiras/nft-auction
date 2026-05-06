

# 拍卖合约 

## 环境配置
```shell
.env                      # 私钥、RPC、预言机地址
foundry.toml              # Foundry 配置
remappings.txt            # 依赖路径映射
```
##  智能合约
```shell
src/
├─ auction/
│  ├─ IAuction.sol        # 拍卖接口
│  ├─ Auction.sol         # 拍卖 V1（可升级）
│  ├─ AuctionV2.sol       # 拍卖 V2（升级版本）
│  └─ AuctionFactory.sol  # 拍卖工厂（创建代理）
├─ chainlink/
│  └─ ChainlinkPriceFeed.sol  # 价格预言机
├─ nft/
│  └─ MyNFT.sol           # 测试 NFT
└─ token/
   └─ TestERC20.sol       # 测试 ERC20
   ```

## 部署脚本
```shell
script/
├─ DeployAll.s.sol        # 部署所有合约
└─ UpgradeAuction.s.sol   # 升级拍卖合约
```
## 测试文件
```shell
test/
├─ AuctionTest.t.sol           # 拍卖核心测试
├─ AuctionUpgradeTest.t.sol    # 拍卖升级测试
├─ AuctionFactoryTest.t.sol    # 工厂测试
├─ MyNFTTest.t.sol             # NFT 测试
├─ TestERC20Test.t.sol         # ERC20 测试
└─ ChainlinkPriceFeedTest.t.sol # 预言机测试


```

## 初始化项目
forge init nft_auction
cd nft_auction

## 安装依赖
forge install openzeppelin/openzeppelin-contracts
forge install openzeppelin/openzeppelin-contracts-upgradeable
forge install smartcontractkit/chainlink-contracts


## 编译合约
forge clean && forge build
## 运行测试
forge test -vvv
或者
forge test --match-path test/AuctionTest.t.sol -vvv
forge test --match-path test/AuctionUpgradeTest.t.sol -vvv
forge test --match-path test/MyNFTTest.t.sol -vv
 ## 显示覆盖率摘要（默认）
forge coverage
## 部署全部合约
forge script script/DeployAll.s.sol --rpc-url sepolia --broadcast --verify
## 升级拍卖合约
forge script script/UpgradeAuction.s.sol --rpc-url sepolia --broadcast --verify

## 本地部署
启动本地网络 (anvil)
anvil

forge script script/DeployAll.s.sol --rpc-url http://localhost:8545 --broadcast










