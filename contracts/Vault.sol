// mint 10% JomEV token for user
// Earn interest
// Stake JomEV token 90%
// Store all the stableCoint token in here

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./EVToken.sol";

contract Vault is Ownable {
    EVToken public evToken;

    uint256 DISTRIBUTION_POINT = 100;
    // provider address to EVToken Balance
    mapping(address => uint256) public EVTokenBalance;
    // provider address to tokenAddress  deposited
    mapping(address => mapping(address => uint256))
        public providerTokenDeposited;
    // token Address to amount
    mapping(address => uint256) public tokenBalance;

    constructor() {}

    function setEVTokenAddress(address _evToken) external onlyOwner {
        evToken = EVToken(_evToken);
    }

    function getEVTokenAddress() external view returns (address) {
        return address(evToken);
    }

    function getEVTokenBalance(address provider)
        external
        view
        returns (uint256)
    {
        return EVTokenBalance[provider];
    }

    function TransferOwner(address NewOwner) external onlyOwner {
        transferOwnership(NewOwner);
    }

    function mintEVToken(
        address Provider,
        uint256 amount_deposited,
        address tokenAddress
    ) external onlyOwner {
        tokenBalance[tokenAddress] = amount_deposited;
        providerTokenDeposited[Provider][tokenAddress] = amount_deposited;
        // Provider get 10% EV Token, Vault get 90% of EV Token
        uint256 Provider_get = (amount_deposited * 10 * DISTRIBUTION_POINT) /
            100;
        uint256 vault_get = (amount_deposited * 90 * DISTRIBUTION_POINT) / 100;
        evToken.mintToken(Provider, Provider_get);
        evToken.mintToken(address(this), vault_get);

        EVTokenBalance[Provider] = Provider_get;
    }

    /*
     * @dev get Token Balance of Vault
     * @param tokenAddress: accepted token address
     */
    function getTokenBalance(address tokenAddress)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return tokenBalance[tokenAddress];
    }

    function getEVTokenBalanceVault() external view returns (uint256) {
        return evToken.balanceOf(address(this));
    }

    function invest(
        address platform,
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {}
}
