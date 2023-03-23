pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DMToken is ERC20, Ownable {

using SafeERC20 for IERC20;

uint256 public inflationRate = 11; // 0.11%
uint256 public lastBlockNumber = block.number;
uint256 public constant blocksPerDay = 5760; // 4 blocks per minute * 60 minutes per hour * 24 hours per day

struct Stake {
uint256 amount;
uint256 blockNumber;
}

address[] private tokenHolders;
mapping(address => Stake) public stakes;

constructor(uint256 initialSupply) ERC20("DMToken", "DMT") {
_mint(msg.sender, initialSupply);
}

function mintInflation() public {
uint256 currentBlockNumber = block.number;
uint256 blocksSinceLastInflation = currentBlockNumber - lastBlockNumber;
uint256 daysSinceLastInflation = blocksSinceLastInflation / blocksPerDay;
uint256 inflationFactor = inflationRate * daysSinceLastInflation;
uint256 inflationAmount = (totalSupply() * inflationFactor) / 10000;
_mint(owner(), inflationAmount);
lastBlockNumber = currentBlockNumber;
emit Transfer(address(0), owner(), inflationAmount);
}

function setInflationRate(uint256 rate) public onlyOwner {
inflationRate = rate;
}

function setInitialSupply(uint256 supply) public onlyOwner {
_mint(msg.sender, supply);
}

function stake(uint256 amount) public {
require(amount > 0, "DMToken: Cannot stake zero tokens");
require(stakes[msg.sender].amount == 0, "DMToken: Cannot stake again until previous stake is withdrawn");
require(balanceOf(msg.sender) >= amount, "DMToken: Insufficient balance");

// Transfer the tokens from the caller to the contract
_transfer(msg.sender, address(this), amount);

// Store the stake information
stakes[msg.sender] = Stake(amount, block.number);

emit Staked(msg.sender, amount);
}

function withdraw() public {
require(stakes[msg.sender].amount > 0, "DMToken: No stake to withdraw");

uint256 stakeAmount = stakes[msg.sender].amount;
uint256 stakeBlockNumber = stakes[msg.sender].blockNumber;

// Calculate the profit share based on the stake amount and the time since the stake was made
uint256 currentBlockNumber = block.number;
uint256 blocksSinceStake = currentBlockNumber - stakeBlockNumber;
uint256 daysSinceStake = blocksSinceStake / blocksPerDay;
uint256 profitShare = (totalSupply() * inflationRate * daysSinceStake) / (10000 * totalStakes());
uint256 profitAmount = (stakeAmount * profitShare) / 100;

// Transfer the stake amount and profit share back to the caller
_transfer(address(this), msg.sender, stakeAmount + profitAmount);

// Reset the stake information
delete stakes[msg.sender];

emit Withdrawn(msg.sender, stakeAmount, profitAmount);
}

function totalStakes() public view returns (uint256) {
uint256 total = 0;
for (uint256 i = 0; i < totalSupply(); i++) {
address stakeholder = tokenHolders[i];
total += stakes[stakeholder].amount;
}
return total;
}

function burn(uint256 amount) public {
require(amount > 0, "DMToken: Cannot burn zero tokens");
require(balanceOf(msg.sender) >= amount, "DMToken: Insufficient balance");

// Burn the tokens from the caller's balance
_burn(msg.sender, amount);

emit Burned(msg.sender, amount);
}

function swap(address token, uint256 amount) public {
require(amount > 0, "DMToken: Cannot swap zero tokens");
require(balanceOf(msg.sender) >= amount, "DMToken: Insufficient balance");

// Transfer the tokens from the caller to this contract
IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

emit Swapped(msg.sender, token, amount);
}

event Staked(address indexed user, uint256 amount);
event Withdrawn(address indexed user, uint256 stakeAmount, uint256 profitAmount);
event Burned(address indexed user, uint256 amount);
event Swapped(address indexed user, address indexed token, uint256 amount);
}
