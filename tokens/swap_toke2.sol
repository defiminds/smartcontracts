// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.4/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.4/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract DMToken is ERC20, ERC20Burnable {
    constructor(uint256 initialSupply) ERC20("DMToken", "DMT") {
        _mint(msg.sender, initialSupply);
    }
    
    function swapWithERC20(address tokenAddress, uint256 amount) public {
        require(IERC20(tokenAddress).approve(msg.sender, amount), "Approval failed");
        require(transferFrom(msg.sender, address(this), amount), "Transfer failed");
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        _mint(msg.sender, amount);
    }
}
