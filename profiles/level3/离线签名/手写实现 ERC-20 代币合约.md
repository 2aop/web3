## 手写实现 ERC-20 代币合约

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DogCoin {
    string private _name; //代币名称。
    string private _symbol; //代币符号。
    uint256 private _totalSupply; //代币总供应量。
    mapping(address => uint256) private _balances; //账户余额映射。
    mapping(address => mapping(address => uint256)) private _allowances; //授权额度映射。
    address public owner; //合约所有者

    event Transfer(address indexed from, address indexed to, uint256 value);//转账事件。
    event Approval(address indexed owner, address indexed spender, uint256 value);//授权事件。

    //在构造函数中初始化代币名称、符号和合约所有者。
    constructor(string memory name, string memory symbol, uint256 totalSupply,address _owner){
        _name = name;
        _symbol = symbol;
        _totalSupply = totalSupply;
        owner = _owner;
    }

    //使用onlyOwner修饰符限制某些函数只能由合约所有者调用。
    modifier onlyOwner {
        require(msg.sender == owner,"not owner");
        _;
    }

    modifier balanceEnough(address _owner, uint256 value) {
        require(_balances[_owner] >= value);
        _;
    }

    modifier allowancesEnough(address from,address target , uint256 value) {
        require(_allowances[from][target] >= value, "allowances not enough");
        _;
    }

    //返回代币名称
    function getName() public view returns(string memory) {
        return _name;
    }
    //返回代币符号
    function getSymbol() public view returns(string memory) {
        return _symbol;
    }
    //返回小数点位
    function decimals() public pure returns(uint256) {
        return 18;
    }
    //返回总供应量
    function getTotalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    //查询账户余额
    function getMyBalance() public view returns(uint256) {
        return _balances[msg.sender];
    }

    //查询授权额度
    function getAllowances(address _owner,address target) public view returns(uint256) {
        return _allowances[_owner][target];
    }

    //实现设置授权额度的函数
    function setAllowances(address _owner, address target ,uint256 value) public {
        _allowances[_owner][target] += value;
        emit Approval(_owner, target, value);
    }

    //实现从调用者地址向另一个地址转移代币的函数
    function tranfer(address target,uint256 value) public balanceEnough(msg.sender,value) {
        _balances[msg.sender] -= value;
        _balances[target] += value;
        emit Transfer(msg.sender, target, value);
    }

    //实现从一个地址向另一个地址转移代币的函数（需要事先授权）
    function tranferFrom(address from, address target, uint256 value) public allowancesEnough(from,target,value) balanceEnough(from,value) {
        _allowances[from][target] -= value;
        _balances[from] -= value;
        _balances[target] += value;
        emit Transfer(from, target, value);
    }

    //实现合约所有者可以增加代币供应量的函数。
    function increaseTotalSupply(address account, uint256 value) public onlyOwner {
        _balances[account] += value;
        _totalSupply += value;
        emit Transfer(address(0), account, value);
    }

    function burn(address account ,uint256 value) public onlyOwner balanceEnough(account , value) {
        _balances[account] -= value;
        _totalSupply -= value;
        emit Transfer(account, address(0), value);

    }



}
```

