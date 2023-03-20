pragma solidity ^0.8.0;

contract PaymentChannel {
    address payable public sender;
    address payable public recipient;
    uint256 public expiration;

    constructor(address payable _recipient, uint256 duration) payable {
        sender = payable(msg.sender);
        recipient = _recipient;
        expiration = block.timestamp + duration;
    }

    function isValidSignature(uint256 amount, bytes memory signature) public view returns (bool) {
        bytes32 message = prefixed(keccak256(abi.encodePacked(address(this), amount)));
        return recoverSigner(message, signature) == sender && block.timestamp < expiration;
    }

    function close(uint256 amount, bytes memory signature) public {
        require(isValidSignature(amount, signature), "Invalid signature or channel expired");
        recipient.transfer(amount);
        selfdestruct(sender);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
