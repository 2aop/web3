pragma solidity ^0.8.17;

/**
  众筹的受益人 和 集资数量 需要部署合约的时候就赋值
  捐款的时候需要判断活动是否结束
*/
contract CrowdedFunding {

    address public immutable benifitor;
    uint256 public immutable fundGoal;
    bool public closed;

    event Withdraw(address add,uint256 amount);

    constructor(address _ad , uint256 goal) {
        benifitor = _ad;
        fundGoal = goal;
    }

    modifier notClosed() {
        require(!closed,"funding is closed");
        _;
    }

   /**
    保存捐款者 与 他的捐款数目 肯定需要一个mapping
    用fundingAmount(变量)来报错捐款余额，不要用this.balance
    用一个mapping来保存已经捐过款的人，不然只有数组，每次都要遍历
   */
    mapping(address => uint256) funders;
    uint256 public fundingAmount;
    mapping(address => bool) donatedFunders;
    address[] public funders;

    function donate(uint256 amount) external notClosed payable  {
        fundingAmount += amount;
        if(!donatedFunders[msg.sender]){
            donatedFunders[msg.sender] = true;
            fundersKey.push(msg.sender);
        }

        funders[msg.sender] += msg.value;

        if(fundingAmount >= fundGoal){
            closed = true;
        }
    }

    function withdrawToBenficator() public payable {
        payable(benifitor).transfer(fundingAmount);
        emit Withdraw(benifitor, fundingAmount);
}







}