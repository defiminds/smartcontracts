pragma solidity ^0.8.0;

contract PlasmaExample {
    address public operator;
    uint256 public blockNumber;
    mapping(uint256 => bytes32) public blocks;

    constructor() {
        operator = msg.sender;
        blockNumber = 0;
    }

    function submitBlock(bytes32 _blockHash) public {
        require(msg.sender == operator, "Only operator can submit blocks");
        blocks[blockNumber] = _blockHash;
        blockNumber++;
    }

    function submitTransaction(uint256 _blockNumber, bytes memory _transaction) public {
        require(_blockNumber < blockNumber, "Block does not exist yet");
        bytes32 merkleRoot = blocks[_blockNumber];
        bytes32 transactionHash = keccak256(_transaction);
        require(verifyTransaction(merkleRoot, transactionHash), "Invalid transaction");
        // Execute transaction
    }

    function verifyTransaction(bytes32 _merkleRoot, bytes32 _transactionHash) public pure returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(_transactionHash));
        for (uint256 i = 0; i < 32; i++) {
            if ((_merkleRoot >> i) & 1 == 1) {
                node = keccak256(abi.encodePacked(node, bytes32(uint256(2)**256-1)));
            } else {
                node = keccak256(abi.encodePacked(bytes32(uint256(2)**256-1), node));
            }
        }
        return node == _merkleRoot;
    }
}
