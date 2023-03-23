// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    uint256 private constant INITIAL_SUPPLY = 14 * 10**9 * 10**18;
    uint256 private constant OWNER_SUPPLY = INITIAL_SUPPLY * 45 / 100;
    uint256 private constant LOCKED_SUPPLY = INITIAL_SUPPLY - OWNER_SUPPLY;

mapping(address => uint256) private _unlockTimes;
mapping(address => uint256) private _balances;
mapping(address => uint256) private _lockedBalances;

constructor() ERC20("My Token", "MTK") {
    _mint(msg.sender, OWNER_SUPPLY);
    _balances[msg.sender] = OWNER_SUPPLY;
    _balances[address(this)] = LOCKED_SUPPLY;
}

function lock(address account, uint256 amount, uint256 unlockTime) public onlyOwner {
    require(amount <= LOCKED_SUPPLY, "MyToken: amount exceeds locked supply");
    require(_unlockTimes[account] < unlockTime, "MyToken: unlock time must be later than current");
    _lockedBalances[account] = _lockedBalances[account] + amount;
    _unlockTimes[account] = unlockTime;
    _transfer(account, address(this), amount);
}


    function unlock() public {
        require(_lockedBalances[msg.sender] > 0, "MyToken: no locked balance");
        require(block.timestamp >= _unlockTimes[msg.sender], "MyToken: not yet unlocked");
        uint256 amount = _lockedBalances[msg.sender];
        _lockedBalances[msg.sender] = 0;
        _transfer(address(this), msg.sender, amount);
    }

    function lockedBalanceOf(address account) public view returns (uint256) {
        return _lockedBalances[account];
    }

    function unlockTimeOf(address account) public view returns (uint256) {
        return _unlockTimes[account];
    }

    function batchTransactions(address[] calldata targets, bytes[] calldata data) external payable {
        require(targets.length == data.length, "Invalid input");
        for (uint i = 0; i < targets.length; i++) {
            (bool success,) = targets[i].call{value: msg.value}(data[i]);
            require(success, "Transaction failed");
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(amount <= _balances[sender] - _lockedBalances[sender], "MyToken: transfer amount exceeds unlocked balance");
        return super.transferFrom(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(amount <= _balances[msg.sender] - _lockedBalances[msg.sender], "MyToken: transfer amount exceeds unlocked balance");
        return super.transfer(recipient, amount);
    }
}
