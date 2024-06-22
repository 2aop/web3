// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
TodoList: 是类似便签一样功能的东西，记录我们需要做的事情，以及完成状态。 1.需要完成的功能

创建任务
修改任务名称
任务名写错的时候
修改完成状态：
手动指定完成或者未完成
自动切换
如果未完成状态下，改为完成
如果完成状态，改为未完成

 思路 ： 首先 任务 有两个基本属性 一个是名字 一个是状态，所以 用struct 搞个结构体
         创建任务，首先需要有一个任务的列表，创建任务的时候生成一个状态为false的任务 push进去
         修改名字及状态，自动切换 既直接对状态取反
*/
contract TodoList {

    struct Task {
        string name;
        bool iscompleted;
    }

    Task[] public list;

    modifier taskExist(uint256 index) {
        require(index < list.length);
        _;
    }

    function createTask(string memory _name) public returns(uint256) {
        list.push(
            Task({
            name : _name,
            iscompleted : false
            })
        );

        return list.length - 1;
    }

    function updateTaskName(uint256 _index,string memory _name) public taskExist(_index) {
        Task storage temp = list[_index];
        temp.name = _name;
    }

    function updateTaskStatus(uint256 _index,bool status) public taskExist(_index) {
        Task storage temp = list[_index];
        temp.iscompleted = status;
    }

    function autoUpdateTaskStatus(uint256 _index) public taskExist(_index) {
        Task storage temp = list[_index];
        temp.iscompleted = !temp.iscompleted;
    }


}