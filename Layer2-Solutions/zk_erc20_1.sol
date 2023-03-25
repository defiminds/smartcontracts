// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

interface IZkSync {
    function depositERC20(
        address _token,
        address _zkSyncAddress,
        uint128 _amount
    ) external;
    function swap(
        address _token,
        address _zkSyncAddress,
        uint128 _amount,
        bytes calldata _zkSyncData
    ) external;
}

contract MyToken is IERC20, IERC20Metadata, ReentrancyGuard {
    using SafeMath for uint256;

    // Token information
    string private _name = "My Token";
    string private _symbol = "MT";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 111000000 * 10 ** _decimals;

    // Balances and allowances
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // ZkSync information
    address private _zkSyncAddress;

    // Events
    event Deposited(address indexed from, uint256 amount);
    event Swapped(address indexed from, uint256 amount);

    constructor(address zkSyncAddress) {
        _zkSyncAddress = zkSyncAddress;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function transferOwnership(address newOwner) public {
        require(
            newOwner != address(0),
            "ERC20: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function depositERC20(address token, uint256 amount) public {
        require(token != address(this), "Cannot deposit MyToken");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(_zkSyncAddress, amount);
        IZkSync(_zkSyncAddress).depositERC20(token, address(this), uint128(amount));
        _mint(msg.sender, amount);
        emit Deposited(msg.sender, amount);
    }

    function swapERC20(address token, uint256 amount, bytes calldata zkSyncData) public nonReentrant {
        require(token != address(this), "Cannot swap MyToken");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(_zkSyncAddress, amount);
        IZkSync(_zkSyncAddress).swap(token, address(this), uint128(amount), zkSyncData);
        emit Swapped(msg.sender, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(
            owner != address(0),
            "ERC20: approve from the zero address"
        );
        require(
            spender != address(0),
            "ERC20: approve to the zero address"
        );

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(
            sender != address(0),
            "ERC20: transfer from the zero address"
        );
        require(
            recipient != address(0),
            "ERC20: transfer to the zero address"
        );

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _transferOwnership(address newOwner) private {
        address oldOwner = owner();
        _setOwner(newOwner);
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
