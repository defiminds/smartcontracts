// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ZKBank {
    uint256 public counter;
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function incrementCounter() public {
        counter++;
    }
}
