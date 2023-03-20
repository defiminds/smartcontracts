pragma solidity ^0.8.0;

contract StateChannelExample {
    mapping(address => uint256) public balances;
    mapping(bytes32 => uint256) public channelBalances;

    struct Channel {
        address participant1;
        address participant2;
        uint256 balance1;
        uint256 balance2;
        uint256 timeout; // The block number at which the channel will automatically close
        bool isOpen;
    }

    mapping(bytes32 => Channel) public channels;

    function openChannel(address _participant1, address _participant2, uint256 _timeout) public {
        bytes32 channelId = keccak256(abi.encodePacked(_participant1, _participant2));
        require(channels[channelId].timeout == 0, "Channel already exists");
        channels[channelId] = Channel({
            participant1: _participant1,
            participant2: _participant2,
            balance1: 0,
            balance2: 0,
            timeout: block.number + _timeout,
            isOpen: true
        });
    }

    function deposit(bytes32 _channelId, uint256 _amount) public {
        Channel storage channel = channels[_channelId];
        require(channel.isOpen, "Channel is closed");
        if (msg.sender == channel.participant1) {
            channel.balance1 += _amount;
        } else if (msg.sender == channel.participant2) {
            channel.balance2 += _amount;
        } else {
            revert("Invalid participant");
        }
    }

    function update(bytes32 _channelId, uint256 _balance1, uint256 _balance2) public {
        Channel storage channel = channels[_channelId];
        require(channel.isOpen, "Channel is closed");
        require(msg.sender == channel.participant1 || msg.sender == channel.participant2, "Invalid participant");
        require(_balance1 + _balance2 == channel.balance1 + channel.balance2, "Invalid balances");
        if (msg.sender == channel.participant1) {
            channel.balance1 = _balance1;
        } else {
            channel.balance2 = _balance2;
        }
    }

    function closeChannel(bytes32 _channelId, uint256 _balance1, uint256 _balance2) public {
        Channel storage channel = channels[_channelId];
        require(channel.isOpen, "Channel is already closed");
        require(msg.sender == channel.participant1 || msg.sender == channel.participant2, "Invalid participant");
        require(_balance1 + _balance2 == channel.balance1 + channel.balance2, "Invalid balances");
        require(block.number >= channel.timeout, "Channel is not yet expired");
        channel.isOpen = false;
        balances[channel.participant1] += _balance1;
        balances[channel.participant2] += _balance2;
    }
}
