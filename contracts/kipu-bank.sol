// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Kipu-bank
 * @dev Smart Contact to deposit and withdraw native tokens.
 */
contract KipuBank {
    mapping(address owner => uint256 amount) private s_bankAccounts;

    error InsufficientBalance(uint256 requested, uint256 available);
    error WithdrawOverLimit();
    error BankIsFull(uint256 amountAvailable);
    error TransactionError();

    uint256 public immutable s_thresholdWithdraw;
    uint256 public immutable s_bankCap;

    event userDeposit(address indexed user, uint256 amountDeposited, uint256 newTotalAmount);
    event userWithdraw(address indexed user, uint256 amountWithdraw, uint256 newTotalAmount);

    /**
     * @dev Set contract deployer as owner
     */
    constructor(
        uint256 _thresholdWithdraw,
        uint256 _bankCap
    ) {
        require(_thresholdWithdraw > 0,"");
        require(_bankCap > 0,"");
        s_thresholdWithdraw = _thresholdWithdraw;
        s_bankCap = _bankCap;
    }

    function deposit() external payable {
        if (address(this).balance + msg.value > s_bankCap) {
            revert BankIsFull(s_bankCap - address(this).balance);
        }

        s_bankAccounts[msg.sender] += msg.value;

        emit userDeposit(msg.sender, msg.value, s_bankAccounts[msg.sender]);
    }

    function _transferTokens(uint256 _amount) private {
        (bool success,) = msg.sender.call{value: _amount}("");
        if(!success) revert TransactionError();
    }

    function withdraw(uint256 _amount) external {
        if(_amount > s_thresholdWithdraw) revert WithdrawOverLimit();
        if (s_bankAccounts[msg.sender] < _amount) revert InsufficientBalance(_amount, s_bankAccounts[msg.sender]);
        
        s_bankAccounts[msg.sender] -= _amount;
        _transferTokens(_amount);

        emit userWithdraw(msg.sender, _amount, s_bankAccounts[msg.sender]);
    }

    function getBalance() external view returns (uint256) {
        return s_bankAccounts[msg.sender];
    }
} 
