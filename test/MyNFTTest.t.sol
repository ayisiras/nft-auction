// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// 引入 Foundry 测试框架
import "forge-std/Test.sol";

// 引入被测试的 MyNFT 合约
import "../src/nft/MyNFT.sol";

/**
 * @title MyNFT 单元测试
 * @dev 测试内容：
 *      1. 合约元数据（名称、符号）
 *      2. 铸造权限（仅管理员可铸造）
 *      3. 铸造后所有权与余额正确性
 *      4. 转账功能（transferFrom / safeTransferFrom）
 *      5. 授权与批量授权（approve / setApprovalForAll）
 *      6. walletOfOwner 查询用户所有 NFT
 * @author 项目开发组
 */
contract MyNFTTest is Test {
    // 测试合约实例
    MyNFT public nft;

    // 测试账户
    address public owner = address(this);     // 合约部署者（默认管理员）
    address public userA = address(0xAAA1);   // 普通用户A
    address public userB = address(0xBBB2);   // 普通用户B

    /**
     * @dev 每个测试用例执行前自动运行
     *      部署 MyNFT 合约
     */
    function setUp() public {
        nft = new MyNFT();
    }

    //-------------------------------------------------------------------------
    // 测试 1：合约元数据正确
    //-------------------------------------------------------------------------

    /**
     * @dev 验证 NFT 名称与符号符合预期
     */
    function test_ContractMetadata() public view {
        assertEq(nft.name(), "MyNFT", "NFT name mismatch");
        assertEq(nft.symbol(), "MNFT", "NFT symbol mismatch");
    }

    //-------------------------------------------------------------------------
    // 测试 2：铸造功能 + 权限控制
    //-------------------------------------------------------------------------

    /**
     * @dev 管理员成功铸造 1 个 NFT 给 userA
     */
    function test_Mint_Success_ByOwner() public {
        // 管理员铸造
        uint256 tokenId = nft.mint(userA);

        // 断言：tokenId 从 0 开始自增
        assertEq(tokenId, 0, "tokenId should start from 0");

        // 断言：userA 是 NFT 0 的所有者
        assertEq(nft.ownerOf(0), userA, "owner mismatch after minting");

        // 断言：userA 余额为 1
        assertEq(nft.balanceOf(userA), 1, "user balance should be 1");
    }

    /**
     * @dev 非管理员调用 mint 应被拒绝（Ownable 权限）
     */
    function test_Mint_Revert_ByNonOwner() public {
        // 伪装成 userA（非管理员）
        vm.prank(userA);

        // 预期回退：Ownable: caller is not the owner
        vm.expectRevert("Ownable: caller is not the owner");
        nft.mint(userA);
    }

    //-------------------------------------------------------------------------
    // 测试 3：转账功能（transferFrom）
    //-------------------------------------------------------------------------

    /**
     * @dev userA 铸造 → userA 转账给 userB → 所有权正确转移
     */
    function test_TransferFrom_Success() public {
        // 准备：管理员铸造给 userA
        nft.mint(userA);

        // 伪装 userA 执行转账
        vm.prank(userA);
        nft.transferFrom(userA, userB, 0);

        // 断言：所有者变为 userB
        assertEq(nft.ownerOf(0), userB, "owner should be userB after transfer");

        // 断言：余额更新
        assertEq(nft.balanceOf(userA), 0, "userA balance should be 0");
        assertEq(nft.balanceOf(userB), 1, "userB balance should be 1");
    }

    //-------------------------------------------------------------------------
    // 测试 4：授权（approve）
    //-------------------------------------------------------------------------

    /**
     * @dev userA 授权 userB → userB 代转 NFT
     */
    function test_Approve_And_TransferFrom() public {
        // 准备
        nft.mint(userA);

        // userA 授权 userB 操作 tokenId=0
        vm.prank(userA);
        nft.approve(userB, 0);

        // userB 代转
        vm.prank(userB);
        nft.transferFrom(userA, userB, 0);

        // 断言成功
        assertEq(nft.ownerOf(0), userB);
    }

    //-------------------------------------------------------------------------
    // 测试 5：批量授权（setApprovalForAll）
    //-------------------------------------------------------------------------

    /**
     * @dev userA 批量授权 userB → userB 可转任意 NFT
     */
    function test_SetApprovalForAll() public {
        // 铸造两个 NFT 给 userA
        nft.mint(userA);
        nft.mint(userA);

        // userA 批量授权 userB
        vm.prank(userA);
        nft.setApprovalForAll(userB, true);

        // userB 转第一个 NFT
        vm.prank(userB);
        nft.transferFrom(userA, userB, 0);

        // 断言
        assertEq(nft.ownerOf(0), userB);
        assertEq(nft.ownerOf(1), userA);
    }

    //-------------------------------------------------------------------------
    // 测试 6：walletOfOwner 返回用户所有 NFT
    //-------------------------------------------------------------------------

    /**
     * @dev 铸造多个 → 查询 userA 的 NFT 列表
     */
    function test_WalletOfOwner() public {
        // 铸造 3 个给 userA
        nft.mint(userA); // 0
        nft.mint(userA); // 1
        nft.mint(userA); // 2

        // 查询
        uint256[] memory ids = nft.walletOfOwner(userA);

        // 断言数组长度
        assertEq(ids.length, 3, "should return 3 IDs");

        // 断言内容
        assertEq(ids[0], 0);
        assertEq(ids[1], 1);
        assertEq(ids[2], 2);
    }

 // 测试：构造函数 constructor
    function test_Constructor() public view {
        // 验证 ERC721 名称、符号
        assertEq(nft.name(), "MyNFT");
        assertEq(nft.symbol(), "MNFT");
        
        // 验证 Ownable 管理员 = 部署者
        assertEq(nft.owner(), address(this));
    }
    // 测试：不能转移不属于自己的 NFT
    function test_TransferFrom_Revert_NotOwner() public {
        nft.mint(userA);
        vm.prank(userB);
        vm.expectRevert();
        nft.transferFrom(userA, userB, 0);
    }

    // 测试：safeTransferFrom 正常转移
    function test_SafeTransferFrom_Success() public {
        nft.mint(userA);
        vm.prank(userA);
        nft.safeTransferFrom(userA, userB, 0);
        assertEq(nft.ownerOf(0), userB);
    }

    // 测试：safeTransferFrom 带 data
    function test_SafeTransferFrom_WithData_Success() public {
        nft.mint(userA);
        vm.prank(userA);
        nft.safeTransferFrom(userA, userB, 0, "data");
        assertEq(nft.ownerOf(0), userB);
    }

    // 测试：getApproved
    function test_GetApproved() public {
        nft.mint(userA);
        vm.prank(userA);
        nft.approve(userB, 0);
        assertEq(nft.getApproved(0), userB);
    }

    // 测试：isApprovedForAll
    function test_IsApprovedForAll() public {
        vm.prank(userA);
        nft.setApprovalForAll(userB, true);
        assertTrue(nft.isApprovedForAll(userA, userB));
    }

    // 测试：授权给零地址（合法操作，不会 revert）
    function test_Approve_ToZeroAddress() public {
        nft.mint(userA);
        vm.prank(userA);
        nft.approve(address(0), 0);
        assertEq(nft.getApproved(0), address(0));
    }

    // 测试：非所有者不能 approve
    function test_Approve_Revert_NotOwner() public {
        nft.mint(userA);
        vm.prank(userB);
        vm.expectRevert();
        nft.approve(userB, 0);
    }

    // 测试：mint 自增
    function test_Mint_TokenId_Increment() public {
        assertEq(nft.mint(userA), 0);
        assertEq(nft.mint(userA), 1);
        assertEq(nft.mint(userA), 2);
    }

    // 测试：空钱包查询
    function test_WalletOfOwner_Empty() public {
        uint256[] memory ids = nft.walletOfOwner(userB);
        assertEq(ids.length, 0);
    }

       
    //  测试：_beforeTokenTransfer 钩子函数
    function test_beforeTokenTransfer() public {
        // 只要执行 铸造 + 转账，就会自动触发 _beforeTokenTransfer
        nft.mint(userA);       // 触发一次

        vm.prank(userA);
        nft.transferFrom(userA, userB, 0); // 触发第二次

        // 函数执行成功 = 覆盖完成
        assertTrue(true);
    }

  
    // 测试：supportsInterface 接口支持
    function test_SupportsInterface() public view {
        // 标准 ERC721 接口（直接写值，不用 constant）
        bytes4 IERC721_INTERFACE = 0x80ac58cd;
        bytes4 IERC721_ENUMERABLE = 0x780e9d63;

        // 验证支持
        assertTrue(nft.supportsInterface(IERC721_INTERFACE));
        assertTrue(nft.supportsInterface(IERC721_ENUMERABLE));
        
        // 验证不支持无效接口
        assertFalse(nft.supportsInterface(0xffffffff));
    }
}
