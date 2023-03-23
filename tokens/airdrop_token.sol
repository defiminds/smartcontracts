// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyBEP20Token is ERC20 {
    address private _owner;
    uint256 private _totalSupply;
    uint256 private _feePercentage = 11; // 0.11%
    uint256 private _maxFeePercentage = 11; // 0.11%
    mapping(address => uint256) private _airdropBalances;
    
    constructor(uint256 totalSupply) ERC20("MyBEP20Token", "MYBEP") {
        _owner = msg.sender;
        _totalSupply = totalSupply * 10 ** decimals();
        _mint(msg.sender, _totalSupply);
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function setFeePercentage(uint256 feePercentage) public {
        require(msg.sender == _owner, "Only owner can adjust fee percentage");
        require(feePercentage <= _maxFeePercentage, "Fee percentage cannot be higher than max");
        _feePercentage = feePercentage;
    }

    function getFeePercentage() public view returns (uint256) {
        return _feePercentage;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 fee = (amount * _feePercentage) / 10000;
        uint256 amountAfterFee = amount - fee;
        _burn(msg.sender, fee); // Burn the fee
        _transfer(_msgSender(), recipient, amountAfterFee);
        return true;
    }

    function airdrop(uint256 percentage) public {
        require(percentage > 0 && percentage <= 100, "Percentage must be between 1 and 100");
        uint256 airdropAmount = (_totalSupply * percentage) / 100;
        _totalSupply -= airdropAmount;
        _airdropBalances[_owner] += airdropAmount;
        emit Transfer(_owner, address(0), airdropAmount);
    }

    function getAirdropBalance(address account) public view returns (uint256) {
        return _airdropBalances[account];
    }

    function transferAirdropBalance(address recipient, uint256 amount) public returns (bool) {
        require(_airdropBalances[msg.sender] >= amount, "Insufficient balance");
        _airdropBalances[msg.sender] -= amount;
        _airdropBalances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
}
