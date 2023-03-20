// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface IZKBank {
    function deposit(address token, uint256 amount) external;
    function withdraw(address token, uint256 amount) external;
    function incrementCounter() external;
    function balances(address account, address token) external view returns (uint256);
}

contract ZKBank is IZKBank {
    uint256 public counter;
    mapping(address => mapping(address => uint256)) public userBalances;

    function deposit(address token, uint256 amount) public override {
        uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        require(allowance >= amount, "Insufficient allowance");
        require(IERC20(token).balanceOf(msg.sender) >= amount, "Insufficient balance");
        userBalances[msg.sender][token] += amount;
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        incrementCounter();
    }

    function withdraw(address token, uint256 amount) public override {
        require(userBalances[msg.sender][token] >= amount, "Insufficient balance");
        userBalances[msg.sender][token] -= amount;
        require(IERC20(token).transfer(msg.sender, amount), "Transfer failed");
        incrementCounter();
    }

    function incrementCounter() public override {
        counter++;
    }

    function balances(address account, address token) public view override returns (uint256) {
        return userBalances[account][token];
    }
}
