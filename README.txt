# 🏦 KipuBank Project for EthKipu Course

A **smart contract** in Solidity that works as a bank for native tokens (ETH).  
It allows users to **deposit** and **withdraw** funds with specific rules.  

**This contract is for educational purposes only and should not be used in production.**

---

## Description

The `KipuBank` smart contract provides the following features:

- **Deposit ETH** associated with the address that interacts with the contract.
- **Withdraw ETH** from the bank to the user’s address. Withdrawals have restrictions:
  - A maximum withdrawal limit per transaction.
  - The user must have sufficient funds.
- **Bank capacity**: the contract cannot hold more than the defined limit of ETH.
- **Counters** for activity tracking:
  - The SC register is the total number of deposits made.
  - The SC register the total number of withdrawals made.
- **Queries available**:
  - Personal balance.
  - Total number of deposits and withdrawals.
  - Remaining capacity in the bank.

---

## Deployment

The contract must be deployed on an **EVM-compatible network** (e.g. Testnet Sepolia).  

Two mandatory parameters must be provided during deployment:

1. **`_thresholdWithdraw`** → Maximum withdrawal allowed per transaction (e.g., `100 wei`).
2. **`_bankCap`** → Total bank capacity (e.g., `1000 wei`).

---

## Interaction 

Once the contract is deployed and you have its **address**, you can interact in the following ways:

### 1. Deposit ETH
- Send ETH directly to the contract address from your wallet (e.g., MetaMask).  
  The contract will automatically register it as a `deposit()`.  
- Alternatively, Call `deposit()` and specify the ETH amount to send.
- Remember there is a limit of the amount of native tokens the bank can hold.

### 2. Withdraw ETH
- Call `withdraw(uint256 _amount)` where `_amount` is written in **wei**.  
    Example: to withdraw `0.1 ETH`, use `100000000000000000`.
- Remember there is a withdraw limit per transaction. Also there is needed to have the amount of native tokens
  associated to the address that calls the function.

### 3. Check your balance
- Call `getBalance()` to get the amount of native tokens that are associated to the address that calls the function.

---

## Example

Address of SC deployed in Sepolia Testnet: 0x1F2d903B82E76af1C2dbE9f2C35579ccf6b73d73
