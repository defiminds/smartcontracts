pragma solidity ^0.8.0;

import "contracts/Verifier.sol"; // Import the Verifier contract

contract ZKRollup {
    struct Transaction {
        uint256 amount;
        address sender;
        address recipient;
        bytes32 proof; // Proof of validity
    }

    Transaction[] public transactions;
    Verifier public verifier;

    constructor(address _verifier) {
        verifier = Verifier(_verifier);
    }

    function addTransaction(uint256 _amount, address _sender, address _recipient, bytes32 _proof) public {
        Transaction memory newTransaction = Transaction({
            amount: _amount,
            sender: _sender,
            recipient: _recipient,
            proof: _proof
        });
        transactions.push(newTransaction);
    }

    function verifyTransaction(uint256 index) public view returns(bool) {
        Transaction storage transaction = transactions[index];
        return verifier.verifyProof(transaction.sender, transaction.recipient, transaction.amount, transaction.proof);
    }
}
