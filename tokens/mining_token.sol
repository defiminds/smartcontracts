pragma solidity ^0.8.0;

contract DMToken {
    // Token information
    string public constant name = "DMToken";
    string public constant symbol = "DM";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 500 ether;

    // Token balances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Contract owner
    address public owner;

    // Matic reserve balance
    uint256 public maticReserve;

    // Hold profit balance
    uint256 public holdProfitBalance;

    // Hold profit unlock time for each user
    mapping(address => uint256) public holdProfitUnlockTime;

    // Mining phase information
    enum MiningPhase { AUTUMN, GROWING_SEASON, HARVEST_SEASON }
    MiningPhase public miningPhase = MiningPhase.AUTUMN;
    uint256 public minedTokens = 0;
    uint256 public maxMinedTokens = 21_000_000 ether;
    uint256 public minedTokensInHoldProfit = 0;
    uint256 public minedTokensInMainBalance = 0;

    // Fee information
    uint256 public feePercent = 1; // 1% by default
    uint256 public feeDiscountPercent = 0;
    uint256 public feeDiscountExpirationTime = 0;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event HoldProfitUnlocked(address indexed user, uint256 amount);

    // Constructor
    constructor() {
        owner = msg.sender;
        balanceOf[owner] = 51 ether;
        balanceOf[address(this)] = totalSupply - balanceOf[owner];
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyDuringMiningPhase(MiningPhase phase) {
        require(miningPhase == phase, "Invalid mining phase");
        _;
    }

    modifier onlyAfterHoldProfitUnlockTime() {
        require(block.timestamp >= holdProfitUnlockTime[msg.sender], "Hold profit not yet unlocked");
        _;
    }

    // Token transfer function
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    // Token transfer function with approval
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= allowance[from][msg.sender], "Insufficient allowance");
        _transfer(from, to, value);
        allowance[from][msg.sender] -= value;
        return true;
    }

    // Approval function
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Fee discount function
    function setFeeDiscount(uint256 percent, uint256 duration) public onlyOwner {
        require(percent <= 100, "Invalid discount percent");
        feeDiscountPercent = percent;
        feeDiscountExpirationTime = block.timestamp + duration;
    }

// Hold profit unlock function
function unlockHoldProfit() public onlyDuringMiningPhase(MiningPhase.GROWING_SEASON) {
    require(holdProfitUnlockTime[msg.sender] == 0, "Hold profit already unlocked");
    holdProfitUnlockTime[msg.sender] = block.timestamp + 24 hours;
    uint256 amount = minedTokensInHoldProfit * balanceOf[msg.sender] / totalSupply;
    balanceOf[msg.sender] += amount;
    holdProfitBalance -= amount;
    minedTokensInHoldProfit -= amount;
    emit HoldProfitUnlocked(msg.sender, amount);
}

// Mining functions
function startMiningSeason() public onlyOwner {
    require(miningPhase == MiningPhase.AUTUMN, "Mining season already started");
    miningPhase = MiningPhase.GROWING_SEASON;
}

function endMiningSeason() public onlyOwner {
    require(miningPhase == MiningPhase.GROWING_SEASON, "Mining season not in progress");
    miningPhase = MiningPhase.HARVEST_SEASON;
}

function mine() public onlyDuringMiningPhase(MiningPhase.GROWING_SEASON) {
    require(msg.sender != address(0), "Invalid sender address");
    require(minedTokens < maxMinedTokens, "Max tokens already mined");

    uint256 minedAmount = 1 ether;
    minedTokens += minedAmount;
    minedTokensInHoldProfit += minedAmount * 20 / 100; // 20% goes to hold profit
    minedTokensInMainBalance += minedAmount * 80 / 100; // 80% goes to main balance

    if (feeDiscountExpirationTime > block.timestamp) {
        // Apply fee discount
        uint256 discountedFee = feePercent * (100 - feeDiscountPercent) / 100;
        maticReserve += minedAmount * discountedFee / 100;
    } else {
        // No fee discount
        maticReserve += minedAmount * feePercent / 100;
    }
}

// Internal transfer function
function _transfer(address from, address to, uint256 value) internal {
    require(from != address(0), "Invalid sender address");
    require(to != address(0), "Invalid recipient address");
    require(value > 0, "Invalid transfer amount");
    require(balanceOf[from] >= value, "Insufficient balance");

    uint256 feeAmount = 0;

    if (miningPhase == MiningPhase.GROWING_SEASON) {
        // Apply hold profit
        uint256 holdProfitAmount = value * minedTokensInHoldProfit / totalSupply;
        holdProfitBalance += holdProfitAmount;
        minedTokensInHoldProfit -= holdProfitAmount;

        // Apply fee
        feeAmount = value * feePercent / 100;
        balanceOf[address(this)] += feeAmount;
        balanceOf[from] -= value;
        balanceOf[to] += value - feeAmount - holdProfitAmount;
    } else {
        // Apply fee only
        feeAmount = value * feePercent / 100;
        balanceOf[address(this)] += feeAmount;
        balanceOf[from] -= value;
        balanceOf[to] += value - feeAmount;
    }

    emit Transfer(from, to, value);
}
}
