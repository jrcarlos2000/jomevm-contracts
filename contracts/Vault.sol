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
    uint256 tokenID;

    uint256 DISTRIBUTION_POINT = 100;

    // referralCode for AAVE
    uint16 constant referralCode = 0;
    // provider address to EVToken Balance
    mapping(address => uint256) public EVTokenBalance;
    // provider address to tokenAddress  deposited
    mapping(address => mapping(address => uint256))
        public providerTokenDeposited;
    // token Address to amount
    mapping(address => uint256) public tokenBalance;
    // tokenId to token Address
    mapping(uint256 => address) public tokenAddress;



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
        address _tokenAddress
    ) external onlyOwner {
        tokenBalance[_tokenAddress] = amount_deposited;
        providerTokenDeposited[Provider][_tokenAddress] = amount_deposited;
        tokenAddress[tokenID] = _tokenAddress;
        tokenID +=1;
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
    function getTokenBalance(address _tokenAddress)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return tokenBalance[_tokenAddress];
    }

    function getEVTokenBalanceVault() external view returns (uint256) {
        return evToken.balanceOf(address(this));
    }

    function invest(
        address platform,
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {}

    //     using SafeERC20 for IERC20;
    
    // mapping(address => uint256) assetAmount;
    // //polygon mainnet
    // // address Pool = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    // // address PoolAddressRegistry = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb;
    // // mumbai
    // address Pool = 0x0940ceaacBF4860d2F7BFA657121B2F26a1676B0;
    // address PoolAddressRegistry = 0x5343b5bA672Ae99d627A1C87866b8E53F47Db2E6;

    // // goerli
    // // address Pool =0x18eE6714Bb1796b8172951D892Fb9f42a961C812;
    // // address PoolAddressRegistry= 0xc4dCB5126a3AfEd129BC3668Ea19285A9f56D15D;

    // // Transfer Ownership

    // /**
    //  * @dev Deposit the entire balance of any supported asset into Aave
    //  */
    // function rebase() external onlyOwner {
    //     // msg.sender = LepakCore
    //     address[] memory whitelistedToken = ILepakCore(msg.sender)
    //         .getWhitelistedToken();
    //     for (uint256 i = 0; i < whitelistedToken.length; i++) {
    //         uint256 balance = IERC20(whitelistedToken[i]).balanceOf(
    //             address(this)
    //         );
    //         if (balance > 0) {
    //             _deposit(whitelistedToken[i], balance);
    //             assetAmount[whitelistedToken[i]] = balance;
    //         }
    //     }
    // }

    // /**
    //  * @dev Deposit asset into Aave, msg.sender = LepakCore
    //  * @param _asset Address of asset to deposit
    //  * @param _amount Amount of asset to deposit
    //  */
    // function deposit(address _asset, uint256 _amount) external {
    //     _deposit(_asset, _amount);
    // }

    // /**
    //  * @dev Deposit asset into Aave
    //  * @param _asset Address of asset to deposit
    //  * @param _amount Amount of asset to deposit
    //  */
    // function _deposit(address _asset, uint256 _amount) internal {
    //     require(_amount > 0, "Must deposit something");
    //     _getPool().supply(_asset, _amount, address(this), referralCode);
    // }

    // // withdraw all back to Treasury contract
    // function withdrawAll() external onlyOwner {
    //     // msg.sender = LepakCore
    //     address[] memory whitelistedToken = ILepakCore(msg.sender)
    //         .getWhitelistedToken();
    //     for (uint256 i = 0; i < whitelistedToken.length; i++) {
    //         uint256 balance = assetAmount[whitelistedToken[i]];
    //         if (balance > 0) {
    //             _withdraw(address(this), whitelistedToken[i], balance);
    //             assetAmount[whitelistedToken[i]] = 0;
    //         }
    //     }
    // }

    // // withdraw individual token
    // function withdraw(
    //     address _recipient,
    //     address _asset,
    //     uint256 _amount
    // ) external onlyOwner {
    //     _withdraw(_recipient, _asset, _amount);
    // }

    // // Core logic of withdraw
    // function _withdraw(
    //     address _recipient,
    //     address _asset,
    //     uint256 _amount
    // ) internal {
    //     require(_amount > 0, "Must withdraw something");
    //     require(_recipient != address(0), "Must specify recipient");

    //     // emit Withdrawal(_asset, _getATokenFor(_asset), _amount);
    //     uint256 withdrawAmount = _getPool().withdraw(
    //         _asset,
    //         _amount,
    //         address(this)
    //     );
    //     require(withdrawAmount == _amount, "Did not withdraw enough");
    //     if (_recipient != address(this)) {
    //         // if not called by withdrawAll, transferback to recipient
    //         IERC20(_asset).safeTransfer(_recipient, _amount);
    //     }
    // }

    // /**
    //  * @dev Approve the spending of all assets by their corresponding aToken,
    //  *      if for some reason is it necessary.
    //  */
    // function safeApproveAllTokens() external {
    //     address pool = address(_getPool());
    //     // approve the pool to spend the Asset
    //     address[] memory whitelistedToken = ILepakCore(msg.sender)
    //         .getWhitelistedToken();
    //     for (uint256 i = 0; i < whitelistedToken.length; i++) {
    //         // Safe approval
    //         IERC20(whitelistedToken[i]).safeApprove(pool, 0);
    //         IERC20(whitelistedToken[i]).safeApprove(pool, type(uint256).max);
    //     }
    // }

    // /**
    //  * @dev Get the current address of the Aave lending pool, which is the gateway to
    //  *      depositing.
    //  * @return Current lending pool implementation
    //  */
    // function _getPool() internal view returns (IAavePool) {
    //     address lendingPool = IPoolAddressesProvider(PoolAddressRegistry)
    //         .getPool();
    //     require(lendingPool != address(0), "Lending pool does not exist");
    //     return IAavePool(lendingPool);
    // }
}
