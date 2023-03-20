pragma solidity ^0.8.0;

interface IValidium {
    function submitTransaction(address _sender, address _recipient, uint256 _amount) external;
}

contract ValidiumExample {
    IValidium public validium;

    constructor(address _validiumAddress) {
        validium = IValidium(_validiumAddress);
    }

    function transfer(address _recipient, uint256 _amount) public {
        validium.submitTransaction(msg.sender, _recipient, _amount);
    }
}
