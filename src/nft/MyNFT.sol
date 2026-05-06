// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title 测试 NFT 合约
 * @dev 标准 ERC721，支持枚举、管理员铸造
 */
contract MyNFT is ERC721, Ownable, ERC721Enumerable {
    /// NFT ID 自增计数器
    uint256 public tokenIdCounter;

    /**
     * @dev 构造函数
     */
    constructor() ERC721("MyNFT", "MNFT") Ownable() {}

    /**
     * @dev 管理员铸造 NFT
     * @param _to 接收地址
     * @return tokenId 新 NFT ID
     */
    function mint(address _to) external onlyOwner returns (uint256) {
        uint256 id = tokenIdCounter++;
        _mint(_to, id);
        return id;
    }

    /**
     * @dev 查询用户所有 NFT
     * @param _owner 用户地址
     * @return NFT ID 数组
     */
    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 bal = balanceOf(_owner);
        uint256[] memory ids = new uint256[](bal);
        for (uint256 i = 0; i < bal; i++) {
            ids[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return ids;
    }

    // 重写必需方法
    function _beforeTokenTransfer(address a, address b, uint256 c, uint256 d) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(a, b, c, d);
    }

    function supportsInterface(bytes4 i) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(i);
    }
}