# DAO-Controlled Smart Contract System

This project implements a Decentralized Autonomous Organization (DAO) governance system where token holders can propose and vote on changes to a managed smart contract.

## Core Components

### GovToken (ERC20)
- Custom ERC20 token that implements voting capabilities
- Token holders can delegate their voting power
- Used for governance voting weight

### MyGovernor
- Main governance contract that manages the proposal and voting system
- Implements OpenZeppelin's Governor contract with the following features:
  - Simple majority voting
  - 1 block voting delay
  - 1 week voting period
  - 4% quorum requirement
  - Timelock integration

### TimeLock
- Adds a time delay between vote passing and execution
- Default 1 hour delay for security
- Controlled by the governance contract
- Acts as the owner of managed contracts

### Box
- Example managed contract that can only be controlled through governance
- Contains a simple storage value that can only be modified through successful DAO proposals

## Governance Flow
1. Token holders create proposals to modify the Box contract
2. Proposals enter a 1 block waiting period
3. Token holders cast votes (for/against) using their GovToken voting power
4. If proposal passes (majority + 4% quorum):
   - Proposal is queued in the TimeLock
   - After 1 hour delay, proposal can be executed
   - Changes are applied to the Box contract

## Security Features
- Time-delayed execution through TimeLock
- Quorum requirements prevent low participation attacks
- Voting power must be delegated before voting
- Admin roles properly configured through TimeLock

This system ensures that all changes to the managed contract must go through a secure, decentralized governance process where token holders have the final say.