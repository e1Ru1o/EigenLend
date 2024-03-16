// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IStakeLend {
    event VaultCreated(address indexed vault, bytes indexed pk);
    event VaultFilled(address indexed depositor, address indexed vault, uint256 indexed deposit);

    /**
     * Creates a vault for a validator
     * @param requiredAmount Amount of USDC to be lendend
     * @param deadline Maximum timestamp for the validator to repay
     * @param rewardBPS Percent to pay as reward to the lenders
     * @param pk Credentials of the validator
     */
    function createVault(uint256 requiredAmount, uint256 deadline, uint256 rewardBPS, bytes calldata pk)
        external
        returns (address vault);

    /**
     * Lenders can fill vaults with assets
     * @dev If the deposit exeeds the required amount only the amount needed to fill the requirement is taken
     * @param vault Address of the vault to lend from
     * @param depositAmount Amount of assets to add to the vault
     */
    function fillVault(address vault, uint256 depositAmount) external returns (uint256 depositedAmount);

    /**
     * @dev Required amount needs to be filled
     * @dev Shares becomes not redeamable
     * @dev Only owner of the vault can trigger it
     * @param vault Address of the vault to lend from
     */
    function lend(address vault) external;

    /**
     * Triggers the validators exit from the beacon chain if
     * a liquidation condition is met
     * @dev Liquidation conditions are:
     *  -undercollateralization
     *  -unmet deadline
     *  -validator inactivity
     * @param vault Vault to liquidate
     * @param _validatorPubKey Public key of the validator
     * @param validatorBalance Balance of the validator
     * @param balanceProof zk-proof of the validator beacon chain balance
     * @param proofTimestamp Timestamp of the zk-proof
     */
    function liquidate(
        address vault,
        bytes calldata _validatorPubKey,
        uint256 validatorBalance,
        bytes32 balanceProof,
        uint256 proofTimestamp
    ) external;

    /**
     * Lender can take back assets + profit
     * @dev Caller should have some shares in the vault
     * @dev Burns all the shares of the lender
     * @param vault Vault to claim shares from
     * @param shares Amount of shares to claim
     * @param receiver Address for the assets to be sent to
     * @param owner Address of the owner of the shares
     */
    function claim(address vault, uint256 shares, uint256 receiver, uint256 owner) external;

    /**
     * Repay loan to avoid liquidation
     * @param vault Vault to repay loan to
     */
    function repay(address vault) external;
    

    function getVaultAddress(uint256 requiredAmount, uint256 deadline, uint256 rewardBPS, bytes32 pk)
        external
        view
        returns (address);
}
