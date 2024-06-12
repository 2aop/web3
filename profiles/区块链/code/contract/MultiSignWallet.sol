pragma solidity ^0.8.17;

contract MultiSignWallet {

    address[] public  owners;
    uint256 public signCount;
    mapping(address => bool) isOwner;
    mapping(uint256 => mapping(address => bool)) approvedTrx;

    struct Transaction {
        uint256 amount;
        address toAd;
        bool excuted;
    }

    Transaction[] public list;

    /**
    部署时候传入地址参数和需要的签名数、
    需要进行参数判断 然后owner用(address => bool)保存起来，为了后面判断isOwner方便
    */
    constructor(address[] memory _owners,uint256 _signCount) {
        require(_owners.length > 0 && _signCount >0,"invalid params");
        require(_owners.length >= signCount,"invalid params");

        signCount = _signCount;
        for(uint256 i = 0; i < _owners.length; i++){
            require(_owners[i] != address(0),"invalid owner");
            require(isOwner[owners[i]],"dulicate owner");

            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
    }

    /**
     后面需要经常做校验 onlyOwner，交易是否存在，交易是否已经执行，交易是否已经被审批，是否有了足够的审批数
    */
    modifier onlyOwner() {
        require(isOwner[msg.sender],"not owner");
        _;
    }

    modifier trxExist(uint256 index) {
        require(index < list.length,"not exist");
        _;
    }

    modifier notExcuted(uint256 index) {
        require(!list[index].excuted,"trx already excuted");
        _;
    }

    modifier notApproved(uint256 index) {
        require(approvedTrx[index][msg.sender],"trx already approved");
        _;
    }

    //调用方法来活动该活动获得的审批数
    modifier enoughApproved(uint256 index) {
        require(getApprovedCount(index) == signCount,"not enough approved");
        _;
    }


    event Deposit(address _sender,uint256 amount);
    event Approve(address _owner,uint256 trxId);
    event Update(address _owner,uint256 trxId,bool fromStatus,bool toStatus);
    event Submit(address owner,uint256 trxid);
    event Execute(uint256 trxid);

    receive() external payable {
        emit Deposit(msg.sender,msg.value);
    }

    function submitTransaction(address _toAd, uint256 _amount) public onlyOwner returns(uint256) {
        list.push(
            Transaction({
                amount : _amount,
                toAd : _toAd,
                excuted : false
            }
        )
    );

    emit Submit(msg.sender, list.length - 1);
        return list.length - 1;
    }

    function approve(uint256 _index) public onlyOwner trxExist(_index) notExcuted(_index) notApproved(_index) {
        approvedTrx[_index][msg.sender] = true;
        emit Approve(msg.sender, _index);
    }

    function updateStatus(uint256 _index,bool status) public onlyOwner trxExist(_index) notExcuted(_index) {
        approvedTrx[_index][msg.sender] = status;
        emit Update(msg.sender, _index, approvedTrx[_index][msg.sender], status);
    }

    function getApprovedCount(uint256 _index) private view returns(uint256) {
        uint256 count = 0;
        for(uint256 i = 0; i < owners.length ; i++){
            if(approvedTrx[_index][owners[i]] == true)
            count++;
        }
        return count;
    }

    function excute(uint256 _index) public  onlyOwner trxExist(_index) notExcuted(_index) enoughApproved(_index) {
        Transaction storage temp =  list[_index];
        temp.excuted = true;
        (bool success,) = temp.toAd.call{value : temp.amount}("");
        require(success,"not ok");
        emit Execute(_index);
    }

}