// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "hardhat/console.sol";

contract SWAPToken {
    string public name = "SWAPToken";
    string public symbol = "SWT";
    uint256 public totalSupply = 11000000000000000000000000; // 11 millions in wei
    uint8 public decimals = 18;
    uint256 public feePercentage = 5;
    address public zeroAddress = 0x0000000000000000000000000000000000000000;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Fee(address indexed from, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function approve(address token_address) external returns (bool success) {
        emit Approval(msg.sender, token_address, 0);
        return true;
    }

    function swap(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Not enough balance");
        uint256 fee = (amount * feePercentage) / 100;
        balanceOf[msg.sender] -= amount;
        balanceOf[zeroAddress] += fee;
        balanceOf[msg.sender] -= fee;
        balanceOf[address(this)] += amount - fee;
        emit Transfer(msg.sender, zeroAddress, fee);
        emit Transfer(msg.sender, address(this), amount - fee);
        emit Fee(msg.sender, fee);
    }

    function transfer(address to, uint256 value) external returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Not enough balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

}
