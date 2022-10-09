// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/**
 * @dev Interface for Aaves Lending Pool
 * Documentation: https://docs.aave.com/developers/core-contracts/pool
 */
interface IAavePool {
    /**
     * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
     * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
     * @param asset The address of the underlying asset to deposit
     * @param amount The amount to be deposited
     * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
     *   is a different wallet
     * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without any middle-man
     **/
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

/**
 * @dev Interface for Aaves Lending Pool
 * Documentation: https://docs.aave.com/developers/core-contracts/pooladdressesprovider#getpool
 */
interface IPoolAddressesProvider {
    /**
     * @notice Get the current address for Aave LendingPool
     * @dev Lending pool is the core contract on which to call deposit
     */
    function getPool() external view returns (address);
}
