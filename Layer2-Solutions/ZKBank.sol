// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract ZKBank {
    uint256 public counter;
    mapping(address => mapping(address => uint256)) public balances;

    function deposit(address token, uint256 amount) public {
        uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        require(allowance >= amount, "Insufficient allowance");
        require(IERC20(token).balanceOf(msg.sender) >= amount, "Insufficient balance");
        balances[msg.sender][token] += amount;
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }

    function withdraw(address token, uint256 amount) public {
        require(balances[msg.sender][token] >= amount, "Insufficient balance");
        balances[msg.sender][token] -= amount;
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
    }

    function incrementCounter() public {
        counter++;
    }
}
