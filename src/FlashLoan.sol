// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

// Vulnerable lending pool
contract LendingPool {
    IERC20 public token;
    mapping(address => uint256) public deposits;

    constructor(IERC20 _token) {
        token = _token;
    }

    function deposit(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    // Flash loan — must be repaid in same transaction
    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= amount, "Insufficient liquidity");

        // Send tokens to borrower
        token.transfer(msg.sender, amount);

        // Expect borrower to do something and repay
        IFlashBorrower(msg.sender).execute(amount);

        // Check repayment — NO FEE CHECKED (vulnerability)
        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan not repaid");
    }
}

interface IFlashBorrower {
    function execute(uint256 amount) external;
}
