pragma solidity ^0.8.0;

contract OptimisticRollup {
    struct Transaction {
        uint256 amount;
        address sender;
        address recipient;
        uint256 blockNumber; // The block number at which the transaction was submitted
    }

    Transaction[] public transactions;
    mapping(address => uint256) public balances;

    function addTransaction(uint256 _amount, address _sender, address _recipient) public {
        require(balances[_sender] >= _amount, "Insufficient funds");
        balances[_sender] -= _amount;
        Transaction memory newTransaction = Transaction({
            amount: _amount,
            sender: _sender,
            recipient: _recipient,
            blockNumber: block.number
        });
        transactions.push(newTransaction);
    }

    function submitBlock() public {
        uint256 startingIndex = transactions.length - 1;
        for (uint256 i = startingIndex; i >= 0; i--) {
            Transaction storage transaction = transactions[i];
            require(transaction.blockNumber <= block.number, "Transaction is not yet confirmed");
            balances[transaction.recipient] += transaction.amount;
        }
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient funds");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}
