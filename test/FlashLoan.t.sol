// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/FlashLoan.sol";

contract MockToken is IERC20 {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract FlashAttacker is IFlashBorrower {
    LendingPool public pool;
    MockToken public token;
    uint256 public stolenAmount;

    constructor(LendingPool _pool, MockToken _token) {
        pool = _pool;
        token = _token;
    }

    function attack(uint256 amount) external {
        pool.flashLoan(amount);
    }

    function execute(uint256 amount) external override {
        stolenAmount = amount;
        token.transfer(address(pool), amount);
    }
}

contract FlashLoanTest is Test {
    MockToken token;
    LendingPool pool;
    FlashAttacker attacker;

    function setUp() public {
        token = new MockToken();
        pool = new LendingPool(IERC20(address(token)));
        attacker = new FlashAttacker(pool, token);
        token.mint(address(pool), 1000 ether);
    }

    function testFlashLoanAttack() public {
        console.log("Pool balance before:", token.balanceOf(address(pool)));
        console.log("Attacker balance before:", token.balanceOf(address(attacker)));
        attacker.attack(1000 ether);
        console.log("Pool balance after:", token.balanceOf(address(pool)));
        console.log("Attacker had access to:", attacker.stolenAmount());
    }
}