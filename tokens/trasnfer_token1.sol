pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenTransfer {
    address public tokenAddress;
    
    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }
    
    function transferTokens(address recipient, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        IERC20 token = IERC20(tokenAddress);
        token.transfer(recipient, amount);
    }
}
