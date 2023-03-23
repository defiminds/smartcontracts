// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
function balanceOf(address account) external view returns (uint256);
}

contract TokenSwap {
address public owner;
uint256 public totalSupply;
mapping(address => uint256) public balances;
mapping(address => uint256) public lastClaimedBlock;
mapping(address => bool) public faucetClaimed;

event TokensSwapped(address indexed fromToken, address indexed toToken, address indexed user, uint256 amount);
event TokensBurned(address indexed token, address indexed user, uint256 amount);
event ProfitDistributed(address indexed user, uint256 amount);

constructor() {
owner = msg.sender;
}

modifier onlyOwner() {
require(msg.sender == owner, "Only owner can call this function.");
_;
}

function swapTokens(address fromToken, address toToken, uint256 amount) external {
require(amount > 0, "Amount must be greater than 0.");
require(IERC20(fromToken).balanceOf(msg.sender) >= amount, "Insufficient balance.");
require(IERC20(fromToken).allowance(msg.sender, address(this)) >= amount, "Not enough allowance.");

IERC20(fromToken).transferFrom(msg.sender, address(this), amount);
IERC20(toToken).transfer(msg.sender, amount);

emit TokensSwapped(fromToken, toToken, msg.sender, amount);
}

function burnTokens(address token, uint256 amount) external {
require(amount > 0, "Amount must be greater than 0.");
require(IERC20(token).balanceOf(msg.sender) >= amount, "Insufficient balance.");

IERC20(token).transfer(address(0), amount);
totalSupply -= amount;
balances[msg.sender] -= amount;

emit TokensBurned(token, msg.sender, amount);
}

function distributeProfit() external {
require(balances[msg.sender] > 0, "You must hold tokens to receive profits.");
require(block.number > lastClaimedBlock[msg.sender] + 100, "You must wait at least 100 blocks to claim profits.");

uint256 profit = balances[msg.sender] / 400;
IERC20(0x0000000000000000000000000000000000000000).transfer(msg.sender, profit);
lastClaimedBlock[msg.sender] = block.number;

emit ProfitDistributed(msg.sender, profit);
}

function claimFaucet() external {
require(!faucetClaimed[msg.sender], "Faucet already claimed.");
require(balances[msg.sender] == 0, "You must not hold any tokens to claim the faucet.");

IERC20(0x0000000000000000000000000000000000000000).transfer(msg.sender, 1500);
faucetClaimed[msg.sender] = true;
}

function transferOwnership(address newOwner) external onlyOwner {
owner = newOwner;
}
}
