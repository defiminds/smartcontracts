// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SWAPToken {
string public name = "SWAPToken";
string public symbol = "SWT";
uint256 public totalSupply = 11000000000000000000000000; // 11 millions in wei
uint8 public decimals = 18;
uint256 public feePercentage = uint256(0.05 * 100); // 5%
address public zeroAddress = 0x0000000000000000000000000000000000000000;
mapping(address => uint256) public balanceOf;
mapping(address => mapping(address => uint256)) public allowance;

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Fee(address indexed from, uint256 value);

constructor() {
    balanceOf[msg.sender] = totalSupply;
}

function approve(address spender, uint256 value) external returns (bool success) {
    allowance[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
}

function deposit() external payable {
    balanceOf[msg.sender] += msg.value;
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

function transferFrom(address from, address to, uint256 value) external returns (bool success) {
    require(balanceOf[from] >= value, "Not enough balance");
    require(allowance[from][msg.sender] >= value, "Not enough allowance");
    balanceOf[from] -= value;
    balanceOf[to] += value;
    allowance[from][msg.sender] -= value;
    emit Transfer(from, to, value);
    return true;
}
}
