// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.4/contracts/token/ERC20/ERC20.sol";

contract DMToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("DMToken", "DMT") {
        _mint(msg.sender, initialSupply);
        _approve(msg.sender, address(this), type(uint256).max);
    }
}
