// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.14;

import {ERC20} from "@solmate/mixins/ERC4626.sol";
import {ERC4626} from "@solmate/mixins/ERC4626.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";

interface IEIP5XXX {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    ///@notice emitted when rewards are claimed
    event RewardsClaimed(
        address indexed receiver,
        address indexed owner,
        address[] tokens,
        uint256[] amounts
    );

    ///@notice emitted when rewards are supplied
    event RewardsSupplied(
        address indexed caller,
        address indexed owner,
        address[] tokens,
        uint256[] amounts
    );

    function rewardAssets() external view returns (address[] memory);

    /*//////////////////////////////////////////////////////////////
                            REWARDS INTERFACE
    //////////////////////////////////////////////////////////////*/

    /**
        @notice returns the amount of tokens that have been earned by depositors
        @param receiver address to receieve the claim of rewards
        @param owner address that has ownership rights to the rewards
        @return rewardAmounts amount of tokens that were redeemed
     */
    function claimRewards(address receiver, address owner)
        external
        returns (uint256[] memory rewardAmounts);

    /**
        @notice Supply rewards to distributor to depositors
        @param assets The assets being supplied
        @param amounts The amounts of each asset
     */
    function supplyRewards(
        address owner,
        address[] memory assets,
        uint256[] memory amounts
    ) external;
}
