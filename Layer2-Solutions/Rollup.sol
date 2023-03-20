pragma solidity ^0.8.0;

contract RollupExample {
    mapping(address => uint256) public balances;
    uint256 public batchIndex;
    uint256 public batchTimestamp;
    bytes32 public batchHash;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function submitBatch() public {
        require(block.timestamp > batchTimestamp + 1 minutes, "Must wait 1 minute between batches");
        require(batchHash != 0, "No pending batch");

        batchIndex++;
        batchTimestamp = block.timestamp;
        bytes32 newBatchHash = keccak256(abi.encodePacked(batchIndex, batchTimestamp, balances));
        batchHash = newBatchHash;
        for (address account : accounts()) {
            balances[account] = 0;
        }
        emit BatchSubmitted(batchIndex, batchTimestamp, newBatchHash);
    }

    function commitBatch(bytes calldata _batch) public {
        require(block.timestamp <= batchTimestamp + 1 minutes, "Batch expired");
        require(batchHash != 0, "No pending batch");
        require(keccak256(_batch) == batchHash, "Invalid batch hash");

        (address[] memory accounts, uint256[] memory values) = abi.decode(_batch, (address[], uint256[]));
        for (uint256 i = 0; i < accounts.length; i++) {
            balances[accounts[i]] += values[i];
        }
        emit BatchCommitted(batchIndex, accounts, values);
    }

    function accounts() public view returns (address[] memory) {
        address[] memory result = new address[](batchIndex);
        for (uint256 i = 1; i <= batchIndex; i++) {
            result[i - 1] = keccak256(abi.encodePacked(batchIndex, i));
        }
        return result;
    }

    event BatchSubmitted(uint256 indexed batchIndex, uint256 indexed batchTimestamp, bytes32 indexed batchHash);
    event BatchCommitted(uint256 indexed batchIndex, address[] accounts, uint256[] values);
}
