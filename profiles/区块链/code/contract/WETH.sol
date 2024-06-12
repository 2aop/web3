// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
WETH 是包装 ETH 主币，作为 ERC20 的合约。 标准的 ERC20 合约包括如下几个

3 个查询
balanceOf: 查询指定地址的 Token 数量
allowance: 查询指定地址对另外一个地址的剩余授权额度
totalSupply: 查询当前合约的 Token 总量
2 个交易
transfer: 从当前调用者地址发送指定数量的 Token 到指定地址。
这是一个写入方法，所以还会抛出一个 Transfer 事件。
transferFrom: 当向另外一个合约地址存款时，对方合约必须调用 transferFrom 才可以把 Token 拿到它自己的合约中。
2 个事件
Transfer
Approval
1 个授权
approve: 授权指定地址可以操作调用者的最大 Token 数量。

  思路 ： balanceOf: 查询指定地址的 Token 数量 ---》首先需要一个mapping类型 来存储 address => uint256 ，然后直接取值
          allowance: 查询指定地址对另外一个地址的剩余授权额度 ----》1：指定地址 对 另外一个地址 这首先需要一个mapping，2 剩余授权额度 所以也对应一个mapping ，
                     所以需要一个变量是 (address => mapping(address => uint256))
          totalSupply: 查询当前合约的 Token 总量 --->直接返回balance即可

          转钱的时候 首先要看转钱人的余额，再看转钱人对被转钱人的授信额度够不够（转钱人对被转钱人的地址不能一样）

*/
contract WETH {

    mapping(address => uint256) balanceMap;
    mapping (address => mapping(address => uint256)) allowanceMap;

    event Transfer(address _sender,address toAd,uint256 amount);
    event Approve(address _sender,address toAd,uint256 amount);
    event Deposit(address _sender,uint256 amount);
    event Withdraw(address _sender,uint256 amount);

    modifier balanceEnough(address _ad, uint256 amount) {
        require(balanceMap[_ad] >= amount);
        _;
    }

    function balaceOf(address _ad) public view returns(uint256) {
        return balanceMap[_ad];
    }

    function allowance(address _ad,address other) public view returns (uint256) {
        return allowanceMap[_ad][other];
    }

    function totalSupply() public view returns(uint256) {
        return address(this).balance;
    }

    function transfer(address _toAd,uint256 amount) public returns(bool)  {
        return transferFrom(msg.sender,_toAd,amount);
    }

    function transferFrom(address _sender,address _toAd, uint256 amount) public balanceEnough(_sender,amount) returns(bool) {
        balanceMap[_sender] -= amount;
        balanceMap[_toAd] += amount;
        allowanceMap[_sender][_toAd] -= amount;
        emit Transfer(_sender, _toAd, amount);
        return true;
    }

    function approve(address _toAd,uint256 amount) public balanceEnough(msg.sender,amount) {
        allowanceMap[msg.sender][_toAd] = amount;
        emit Approve(msg.sender, _toAd, amount);
    }

    function deposit() public payable  {
        balanceMap[msg.sender] = msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public balanceEnough(msg.sender,amount) {
        balanceMap[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    fallback() external payable {
        deposit();
    }

    receive() external payable {
        deposit();
    }
}