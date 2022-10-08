// mint 10% JomEV token for user
// Earn interest 
// Stake JomEV token 90%
// Store all the stableCoint token in here

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Vault is Ownable {

    function mintEVToken(address User, uint256 amount_deposited, address tokenAddress) external onlyOwner{}

    function getTokenBalance(address tokenAddress) external OnlyOwner returns(uint256){}

    function getEVTokenBalance() external onlyOwner returns(uint256){}
    
    function invest(address platform, address tokenAddress, uint256 amount) external onlyOwner{}


}