// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// this contract will be controlled by DAO voting
contract Box is Ownable {
    constructor() Ownable(msg.sender) {}
    uint256 private s_number;

    event NumberChanged(uint256 newValue);
    
    function store(uint256 newValue) public onlyOwner {
        s_number = newValue;
        emit NumberChanged(newValue);
    }

    function getNumber() public view returns (uint256) {
        return s_number;
    }
}
