// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/*
存钱罐合约
所有人都可以存钱
  ETH
只有合约 owner 才可以取钱
只要取钱，合约就销毁掉 selfdestruct
扩展：支持主币以外的资产
ERC20
ERC721

思路 ： 所有人都可以存钱 : 既实现一个receive() 因为 需要接受以太币 所以需要 payable 修饰
        只有合约 owner 才可以取钱: 1 ：首先需要实现一个withdraw方法 2：需要校验是否是owner，所以owner需要在创建合约的时候就要指明，
            所以在constructor()方法里面赋值。因为是校验 可以写成一个modifier 方便复用。
        只要取钱，合约就销毁掉 selfdestruct ：所以在合约里面实现selfdestruct(payable(msg.sender));但是^0.8.24版本 selfdestruct 已经被遗弃了，
            所以手动将合约剩余的钱转出。
        支持主币以外的资产：ERC20和ERC721是以太坊区块链上使用的两种标准接口，用于创建和管理代币。它们定义了一组通用的接口，使得代币在不同的应用和平台之间具有互操作性
            IERC20转账有两种 1 ： transfer(address recipient, uint256 amount) recipient：接收代币的地址。amount：要转移的代币数量
                             2：transferFrom(address sender, address recipient, uint256 amount) sender：发送代币的账户地址。recipient：接收代币的账户地址。amount：要转移的代币数量
            IERC721 : transferFrom(address from, address to, uint256 tokenId) from：NFT 当前的拥有者。to：NFT 新的接收者。tokenId：要转移的 NFT 的唯一标识符。
*/
contract Bank {

    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    event Deposit(address _sender,uint256 amount);
    event Withdraw(address _sender,uint256 amount);
    event ERC20Deposit(address _sender,address _toAd,uint256 amount);
    event ERC20Withdraw(address _sender,address _toAd,uint256 amount);
    event ERC721Deposit(address _sender,address _toAd,uint256 tokenId);
    event ERC721Withdraw(address _sender,address _toAd,uint256 tokenId);

    receive() external payable {
        emit Deposit(msg.sender,msg.value);
    }

    modifier onlyOnwer() {
        require(owner == msg.sender,"not owner");
    _;
    }

    modifier balanceEnough(uint256 amount) {
        require(address(this).balance >= amount,"balance not enough");
    _;
    }

    modifier ERC20balanceEnough(address token,uint256 amount) {
        require(IERC20(token).balanceOf(address(this))  >= amount,"balance not enough");
    _;
    }

    function withdraw(uint256 amount) external onlyOnwer balanceEnough(amount) {
        payable(msg.sender).transfer(amount);
//        selfdestruct(payable(msg.sender));
        emit Withdraw(msg.sender,amount);
    }


    // 接受ERC20代币 从调用者转到该合约
    function depositERC20(address token,uint256 amount) external {
        IERC20(token).transferFrom(msg.sender,address(this),amount);
        emit ERC20Deposit(msg.sender,address(this),amount);
    }

   // 取出ERC20代币 从合约转到owner
    function withdrawERC20(address token,uint256 amount) external onlyOnwer ERC20balanceEnough(token,amount) {
        IERC20(token).transfer(owner,amount);
        emit ERC20Withdraw(address(this),owner,amount);
    }

   // 接受ERC721代币 从调用者转到该合约
    function depositERC721(address token,uint256 tokenId) external {
        IERC721(token).transferFrom(msg.sender,address(this),tokenId);
        emit ERC721Deposit(msg.sender,address(this),tokenId);
    }
// 取出ERC721代币 从合约转到owner
    function withdrawERC721(address token,uint256 amount) external onlyOnwer {
        IERC721(token).transferFrom(address(this),msg.sender,amount);
        emit ERC721Withdraw(address(this),msg.sender,amount);
    }


}