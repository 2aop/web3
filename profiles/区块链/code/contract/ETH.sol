pragma solidity ^0.8.17;

contract ETH2 {

    address public immutable owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(owner == msg.sender,"not owner");
        _;
    }

    modifier balanceEnough(uint256 amount) {
        require(address(this).balance >= amount);
        _;
    }

    event Depoist(address _sender,uint256 amount);
    event Withdraw(address _sender,uint256 amount);

    receive() external payable {
        emit Depoist(msg.sender,msg.value);
    }

    /**
    transfer 如果出现直接出异常
    send 会返回true/false
    call 需要手动处理返回值
    */
    function withdraw(uint256 amount) public onlyOwner balanceEnough(amount) {
     // payable(msg.sender).transfer(amount);

     // bool success =  payable(msg.sender).send(amount);
     // require(success,"withdraw failed");

     // (bool success,) = msg.sender.call{value : amount}("");
     // require(success,"withdraw failed");
        emit Withdraw(msg.sender, amount);
    }

}