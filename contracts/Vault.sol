// mint 10% JomEV token for user
// Earn interest 
// Stake JomEV token 90%
// Store all the stableCoint token in here

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./DummyToken.sol";

contract Vault is Ownable {

    DummyToken public EVToken;

    // user address to EVToken Balance 
    mapping(address => uint256) EVTokenBalance;
    uint256 DISTRIBUTION_POINT = 100;
    // user address to tokenAddress  deposited
    mapping(address => mapping(address=>uint256)) UserTokenDeposited;
    // token Address to amount 
    mapping(address => uint256) tokenBalance;

    constructor(address _evToken){
        EVToken = ERC20(_evToken);
    }

    function TransferOwner(address NewOwner) external onlyOwner{
        transferOwnership(NewOwner);
    }

    function mintEVToken(address User, uint256 amount_deposited, address tokenAddress) external onlyOwner{
        tokenBalance[tokenAddress] = amount_deposited;
        UserTokenDeposited[User][tokenAddress] = amount_deposited;
        // User get 10% EV Token, Vault get 90% of EV Token
        uint256 user_get = (amount_deposited * 10 * DISTRIBUTION_POINT) /100;
        uint256 vault_get = (amount_deposited * 90 * DISTRIBUTION_POINT) /100;
        EVToken.mintToken(User, user_get);
        EVToken.mintToken(address(this),vault_get);

        EVTokenBalance[User] = user_get;
    }


    /*
    * @dev get Token Balance of Vault
    * @param tokenAddress: accepted token address
     */
    function getTokenBalance(address tokenAddress) external view onlyOwner returns(uint256){
        return tokenBalance[tokenAddress];
    }

    function getEVTokenBalance() external onlyOwner returns(uint256){
        return EVToken.balanceOf(address(this));
    }
    
    function invest(address platform, address tokenAddress, uint256 amount) external onlyOwner{}


}