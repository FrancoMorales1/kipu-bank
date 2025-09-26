// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

/**
 * @title Kipu-bank
 * @dev Smart Contact to deposit and withdraw native tokens.
 */
contract KipuBank {

    /// @notice Mapping that stores each user's balance.
    mapping(address owner => uint256 amount) private s_bankAccounts;

    /// @notice Limit of maximum withdraw per call.
    uint256 public immutable i_thresholdWithdraw;
    
    /// @notice Limit of native tokens the bank can hold.
    uint256 public immutable i_bankCap;
    
    /// @notice Counter of the total number of deposits.
    uint256 public s_depositCount;
    
    /// @notice Counter of the total number of withdrawals.
    uint256 public s_withdrawCount;

    /// @notice Event emitted when an user deposits native tokens in the bank.
    event UserDeposit(address indexed user, uint256 amountDeposited, uint256 newTotalAmount);

    /// @notice Event emitted when an user withdraw native tokens from the bank.
    event UserWithdraw(address indexed user, uint256 amountWithdraw, uint256 newTotalAmount);

    /**
    * @notice Thrown when a user tries to withdraw more than their current balance.
    * @param requested The amount requested for withdrawal.
    * @param available The balance available in the user account.
    */
    error InsufficientBalance(uint256 requested, uint256 available);

    /// @notice Thrown when a withdrawal amount exceeds the allowed threshold.
    error WithdrawOverLimit();
    
    /**
    * @notice Thrown when a deposit would exceed the total bank capacity.
    * @param amountAvailable Remaining space before reaching the bank cap.
    */
    error BankIsFull(uint256 amountAvailable);

    /// @notice Thrown when a transfer of native tokens fails.
    error TransactionError();

    /// @notice Thrown when the constructor receives as withdraw threshold 0.
    error InvalidThreshold();

    /// @notice Thrown when the constructor receives as bank cap 0.
    error InvalidBankCap();
    
    /// @notice Thrown when the an user tries to withdraw 0 native tokens.
    error InvalidWithdrawAmount();
    
    /**
    * @notice Makes sure the bank has enough space for the incoming deposit.
    * @param _amount The amount of native tokens being deposited.
    */
   
    modifier withinBankCap(uint256 _amount) {
        if (address(this).balance + _amount > i_bankCap) {
            revert BankIsFull(i_bankCap - address(this).balance);
        }
        _;
    }

    /**
    * @notice Makes sure the withdrawal amount is greater than 0.
    * @param _amount The amount of native tokens being withdraw.
    */

    modifier validAmount(uint256 _amount) {
        if (_amount == 0) revert InvalidWithdrawAmount();
        _;
    }

    /**
    * @notice Makes sure the withdrawal amount does not exceed the threshold.
    * @param _amount The amount of native tokens being withdraw.
    */

    modifier withinThreshold(uint256 _amount) {
        if (_amount > i_thresholdWithdraw) revert WithdrawOverLimit();
        _;
    }

    /**
    * @notice Makes sure the user has enough balance for the withdrawal.
    * @param _amount The amount of native tokens being withdraw.
    */

    modifier hasEnoughBalance(uint256 _amount) {
        if (s_bankAccounts[msg.sender] < _amount) {
            revert InsufficientBalance(_amount, s_bankAccounts[msg.sender]);
        }
        _;
    }

    /**
    * @notice Initializes the contract with withdrawal threshold and bank capacity.
    * @param _thresholdWithdraw The maximum amount allowed per withdrawal transaction.
    * @param _bankCap The maximum total amount of native tokens the bank can hold.
    */

    constructor(
        uint256 _thresholdWithdraw,
        uint256 _bankCap
    ) {
        if (_thresholdWithdraw == 0) revert InvalidThreshold();
        if (_bankCap == 0) revert InvalidBankCap();
        i_thresholdWithdraw = _thresholdWithdraw;
        i_bankCap = _bankCap;
        s_depositCount = 0;
        s_withdrawCount = 0;
    }

    /// @notice Redirect direct transfers so users must use deposit function.
    receive() external payable {
        this.deposit();
    }

    /**
    * @notice Allows a user to deposit native tokens (ETH) into their personal vault.
    * @dev Can revert with {BankIsFull} if the deposit would exceed the bank capacity.
    * Emits a {UserDeposit} event when completed.
    */

    function deposit()
    external
    payable
    withinBankCap(msg.value)
    {
        s_bankAccounts[msg.sender] += msg.value;
        s_depositCount += 1;

        emit UserDeposit(msg.sender, msg.value, s_bankAccounts[msg.sender]);
    }

    /**
    * @notice Allows a user to withdraw their native tokens from the bank account.
    * @dev Can revert with {WithdrawOverLimit} if amount exceeds the withdrawal threshold.
    * Can revert with {InsufficientBalance} if user has insufficient funds.
    * Emits a {UserWithdraw} event when completed.
    * @param _amount The amount of tokens to withdraw.
    */

    function withdraw(uint256 _amount) 
    external
    validAmount(_amount) 
    withinThreshold(_amount) 
    hasEnoughBalance(_amount)
    {
        s_bankAccounts[msg.sender] -= _amount;
        s_withdrawCount += 1;
        
        _transferTokens(_amount);

        emit UserWithdraw(msg.sender, _amount, s_bankAccounts[msg.sender]);
    }

    /**
    * @notice Internal helper to transfer native tokens safely.
    * @dev Can revert with {TransactionError} if the transfer fails.
    * @param _amount The amount of native tokens to transfer.
    */

    function _transferTokens(uint256 _amount) private {
        (bool success,) = msg.sender.call{value: _amount}("");
        if(!success) revert TransactionError();
    }

    /**
    * @notice Returns the amount of native tokens stored to caller’s address.
    * @return The amount of native tokens stored for the caller.
    */

    function getBalance() external view returns (uint256) {
        return s_bankAccounts[msg.sender];
    }

    /**
    * @notice Returns the number of deposits made.
    * @return The number of deposits made.
    */

    function getDepositCount() external view returns (uint256) {
        return s_depositCount;
    }

    /**
    * @notice Returns The number of withdraw made.
    * @return The number of withdraw made.
    */

    function getWithdrawCount() external view returns (uint256) {
        return s_withdrawCount;
    }

    /**
    * @notice Returns the available space in the bank.
    * @return The available space in the bank.
    */

    function getAvailableBankSpace() external view returns (uint256) {
        return i_bankCap - address(this).balance;
    }
} 
