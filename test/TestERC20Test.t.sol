// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/token/TestERC20.sol";

contract TestERC20Test is Test {
    TestERC20 public token;

    function setUp() public {
        token = new TestERC20();
    }

    function test_token_info() public view {

        assertEq(token.name(), "TestToken");
        assertEq(token.symbol(), "TTK");
    }

    function test_mint() public {
        token.mint(address(0x1), 1000 ether);
        assertEq(token.balanceOf(address(0x1)), 1000 ether);
    }
}