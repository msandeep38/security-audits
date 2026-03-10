# Smart Contract Security Audits
by Mulpur Sandeep | CSE Student | Web3 Security Researcher
Currently pursuing: CompTIA CySA+ | PenTest+

## Exploit Research

### 001 - Reentrancy Attack
- **Vulnerability:** State variable updated after external call
- **Impact:** Complete contract drainage
- **Proof of Concept:** Attacker deposits 1 ETH, drains 4 ETH from victims
- **Files:** `src/VulnerableBank.sol` `test/ReentrancyExploit.t.sol`
- **Result:** Bank balance = 0, Attacker balance = 5 ETH

## Tools
- Slither (static analysis)
- Foundry (exploit development)
- Solc-select (compiler management)
Smart contract vulnerability research and security audit reports | Web3 Security
