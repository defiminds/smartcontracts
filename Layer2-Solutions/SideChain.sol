pragma solidity ^0.8.0;

contract SidechainExample {
    address public mainChain;
    mapping(address => uint256) public balances;

    constructor(address _mainChain) {
        mainChain = _mainChain;
    }

    function deposit(uint256 _amount) public {
        balances[msg.sender] += _amount;
        require(msg.sender.call{value: _amount}(""), "Deposit failed");
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        require(mainChain.call(abi.encodeWithSignature("withdraw(address,uint256)", msg.sender, _amount)), "Withdrawal failed");
    }
}
