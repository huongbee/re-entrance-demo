// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

contract Reentrance {
    mapping (address => uint256) usersBalance;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function getAddrBalance(address u) public view returns(uint){
        return usersBalance[u];
    }
    // Helper function to check the balance of this contract
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function deposit() public payable{
        usersBalance[msg.sender] += msg.value;
    }

    function withdraw() public {
        (bool sent, ) = msg.sender.call{value: usersBalance[msg.sender]}("");
        require(sent, "Failed to send Ether");
        usersBalance[msg.sender] = 0;
    }

    function withdrawBalance_fixed() external{
        // to protect against re-entrancy, the state variable
        // has to be change before the call
        uint amount = usersBalance[msg.sender];
        usersBalance[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function withdrawBalance_fixed_2() external{
        // send() and transfer() are safe against reentrancy
        // they do not transfer the remaining gas
        // and they give just enough gas to execute few instructions
        // in the fallback function (no further call possible)
        address payable payable_addr = payable(msg.sender);
        payable_addr.transfer(usersBalance[msg.sender]);
        usersBalance[msg.sender] = 0;
    }

}
