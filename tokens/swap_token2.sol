pragma solidity ^0.8.0;

contract SwapContract {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lastClaimed;
    address public owner;
    uint256 public totalSupply = 5 * 10**15;
    uint256 public exchangeRate = 100; // 1 token = 100 units
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Claim(address indexed from, uint256 value);
    
    constructor() {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }
    
    function swapToken(address _token, uint256 _amount) public {
        // Transfer tokens from the sender to the contract
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        
        // Calculate the number of units to mint and transfer to the sender
        uint256 units = _amount * exchangeRate;
        balances[msg.sender] += units;
        totalSupply += units;
        
        emit Transfer(address(0), msg.sender, units);
    }
    
    function burn(uint256 _amount) public {
        // Check that the sender has enough balance to burn
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        totalSupply -= _amount;
        
        emit Burn(msg.sender, _amount);
    }
    
    function claim() public {
        // Calculate the amount of profit the sender can claim
        uint256 elapsed = block.timestamp - lastClaimed[msg.sender];
        uint256 amount = balances[msg.sender] * elapsed * 25 / 365 / 86400 / 10000;
        require(amount > 0, "No profit to claim");
        
        // Update the last claimed time and transfer the profit to the sender
        lastClaimed[msg.sender] = block.timestamp;
        require(IERC20(address(this)).transfer(msg.sender, amount), "Transfer failed");
        
        emit Claim(msg.sender, amount);
    }
    
    function claimOne() public {
        // Check that the sender has not claimed in the last 24 hours
        require(lastClaimed[msg.sender] + 86400 < block.timestamp, "Already claimed today");
        
        // Transfer one unit to the sender
        require(balances[msg.sender] > 0, "Insufficient balance");
        balances[msg.sender] -= 1;
        totalSupply -= 1;
        lastClaimed[msg.sender] = block.timestamp;
        
        emit Transfer(msg.sender, address(0), 1);
    }
    
    function transferOwner(address _newOwner) public {
        require(msg.sender == owner, "Only owner can call this function");
        owner = _newOwner;
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
