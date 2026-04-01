// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
  BKNToken (ERC-20) — scaffold

  How you'll use it later:
  1) Deploy to a testnet (Base Sepolia / Polygon Amoy)
  2) Put the deployed address in Flutter:
     --dart-define=BKN_TOKEN_ADDRESS=0x...
  3) Transfer tokens on-chain and store tx_hash in Supabase.

  Requires OpenZeppelin:
    npm i @openzeppelin/contracts
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BKNToken is ERC20, Ownable {
    constructor() ERC20("BKN Token", "BKN") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
