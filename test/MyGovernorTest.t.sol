// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {GovToken} from "../src/GovToken.sol";
import {Box} from "../src/Box.sol";

contract MyGovernorTest is Test {
    MyGovernor public governor;
    GovToken public token;
    TimeLock public timelock;
    Box public box;
    address public user = makeAddr("user"); // user of the protocol
    address[] public proposers;
    address[] public executors;
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 1 hours;
    uint256[] public values;
    bytes[] public calldatas;
    address[] public targets;

    function setUp() public {
        token = new GovToken();
        token.mint(user, INITIAL_SUPPLY);
        vm.startPrank(user);
        token.delegate(user);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(token, timelock);
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();
        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0)); // anybody can execute a passed proposal
        timelock.revokeRole(adminRole, user);
        box = new Box();
        box.transferOwnership(address(timelock));
        vm.stopPrank();
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }

    function TestGovernanceUpdatedBox() public {
        uint256 valueToStore = 888;
        // first propose the change
        string memory description = "Propose to update the box value";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);
        values.push(0); // not sending eth
        calldatas.push(encodedFunctionCall);
        targets.push(address(box));
        // propose the change
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        // queue the proposal
        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);
        string memory reason = "Proposal passed";
        uint8 voteWay = 1;
        vm.startPrank(user);
        governor.castVoteWithReason(proposalId, voteWay, reason);
        vm.stopPrank();
        // execute the proposal
        assertEq(box.getNumber(), valueToStore);
        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);
        governor.queue(targets, values, calldatas, keccak256(bytes(description)));
        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);
        governor.execute(targets, values, calldatas, keccak256(bytes(description)));
        assertEq(box.getNumber(), valueToStore);
    }
}
