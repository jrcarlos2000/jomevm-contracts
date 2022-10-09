// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EVToken is ERC20 {
    address immutable owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000 * 1e18);
        owner = msg.sender;
    }

    function faucet() external {
        _mint(msg.sender, 1000 * 1e18);
    }

    function mintToken(address receiver, uint256 amount) external {
        _mint(receiver, amount);
    }
}
