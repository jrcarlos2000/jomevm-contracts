// mint 10% JomEV token for user
// Earn interest 
// Stake JomEV token 90%
// Store all the stableCoint token in here

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IVault {

    function mintEVToken(address User, uint256 amount_deposited, address tokenAddress) external;

    function getTokenBalance(address tokenAddress) external  returns(uint256);

    function getEVTokenBalance() external  returns(uint256);
    
    function invest(address platform, address tokenAddress, uint256 amount) external;


}