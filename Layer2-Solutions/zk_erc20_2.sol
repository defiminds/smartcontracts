// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ZkERC20 is ERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public owner;
    uint256 public constant totalSupply = 111000000 ether;

    constructor() ERC20("ZkERC20", "ZKERC20") {
        owner = msg.sender;
        _mint(msg.sender, totalSupply);
    }

    function deposit(IERC20 token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        token.safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function swap(IERC20 token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");
        token.safeTransferFrom(msg.sender, address(this), amount);
        _burn(msg.sender, amount);
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Only the owner can transfer ownership");
        owner = newOwner;
    }

    function burn(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        _burn(msg.sender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, recipient, amount);
        return true;
    }
}
