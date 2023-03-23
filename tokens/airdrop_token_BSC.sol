// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    address private owner;
    uint256 private fee;

    mapping(address => uint256) public lastClaimTime;
    address[] public tokenHolders;

    constructor() ERC20("MyToken", "MTK") {
        owner = msg.sender;
        _mint(msg.sender, 5000000000000000 * 10 ** decimals());
        fee = 11; // 0.11%
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        uint256 burnFee = (amount * fee) / 10000;
        super._transfer(sender, recipient, amount);
        super._transfer(sender, address(0), burnFee);

        // add new token holder to array if they are receiving tokens for the first time
        if (balanceOf(recipient) == amount && lastClaimTime[recipient] == 0) {
            tokenHolders.push(recipient);
        }
    }

    function setFee(uint256 _fee) external {
        require(msg.sender == owner, "Only the owner can set the fee.");
        require(_fee <= 11, "Fee must be less than or equal to 0.11%.");
        fee = _fee;
    }

    function airdrop(uint256 percentage, uint256 numHours) external {
        require(msg.sender == owner, "Only the owner can initiate airdrop.");
        uint256 totalSupply = totalSupply();
        uint256 airdropAmount = (totalSupply * percentage) / 100;
        uint256 numHodlers = tokenHolders.length;
        uint256 amountPerHodler = airdropAmount / numHodlers;
        for (uint256 i = 0; i < numHodlers; i++) {
            address hodler = tokenHolders[i];
            uint256 timeSinceLastClaim = block.timestamp - lastClaimTime[hodler];
            if (timeSinceLastClaim >= numHours * 3600) {
                super._transfer(address(this), hodler, amountPerHodler);
                lastClaimTime[hodler] = block.timestamp;
            }
        }
    }
}
