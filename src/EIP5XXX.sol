// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.14;

import {ERC20} from "@solmate/mixins/ERC4626.sol";
import {ERC4626} from "@solmate/mixins/ERC4626.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";

import {IEIP5XXX} from "./IEIP5XXX.sol";
import {ArrayLib} from "../lib/ArrayLib.sol";

/**
    @title EIP5XXXX
    @author DevBear (https://twitter.com/itsdevbear) & Quant Bear (https://github.com/quant-bear)
    @notice EIP5XXX represents a vault in which depostiors can also earn rewards in ERC20 tokens.
 */
abstract contract EIP5XXX is IEIP5XXX, ERC4626 {
    using SafeTransferLib for ERC20;
    using ArrayLib for uint256[];
    /*//////////////////////////////////////////////////////////////
                             REWARDS STORAGE
    //////////////////////////////////////////////////////////////*/

    // Store a list of rewardAssets for iteration
    address[] public rewardAssets;

    /// @notice dividend container lookup by token address
    mapping(address => RewardsContainer) private containers;

    /**
       @notice The container stores information about the dividend program
     * @param earnedPerShare earned rewards per share
     * @param earnedRewards The total number of rewards that have been earned
     * @param joinedAt The time when the user joined the rewards system
     * @param redeemableRewards The available rewards that can be redeemed
     */
    struct RewardsContainer {
        uint256[] earnedPerShare;
        uint256 earnedRewards;
        mapping(address => uint256) joinedAt;
        mapping(address => uint256) redeemableRewards;
    }

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
        virtual
        returns (uint256[] memory rewardAmounts)
    {
        uint256 len = rewardAssets.length;
        for (uint256 i = 0; i < len; ) {
            address rewardAsset = rewardAssets[i];
            _claimRewards(
                owner,
                rewardAsset,
                rewardAmounts[i] = _pendingRewards(owner, rewardAsset)
            );
            ERC20(rewardAsset).transfer(receiver, rewardAmounts[i]);
            // safe unchecked: iteration is safe
            unchecked {
                i++;
            }
        }
        emit RewardsClaimed(receiver, owner, rewardAssets, rewardAmounts);
    }

    /**
        @notice Supply rewards to distributor to depositors
        @param assets The assets being supplied
        @param amounts The amounts of each asset
     */
    function supplyRewards(
        address owner,
        address[] memory assets,
        uint256[] memory amounts
    ) external virtual {
        uint256 len = assets.length;
        for (uint256 i = 0; i < len; ) {
            address rewardAsset = assets[i];
            uint256 amount = amounts[i];
            // safe unchecked: cannot reasonably overflow
            containers[rewardAsset].earnedRewards += amount;
            ERC20(rewardAsset).safeTransferFrom(owner, address(this), amount);

            // safe unchecked: iteration is safe
            unchecked {
                ++i;
            }
        }
        emit RewardsSupplied(msg.sender, owner, rewardAssets, amounts);
    }

    /*//////////////////////////////////////////////////////////////
                             INTERNAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function _setRewardsSinceLastCheck(address rewardAsset) internal {
        uint256 totalShares = totalSupply;
        RewardsContainer storage c = containers[rewardAsset];
        bool noShares = totalShares == 0;
        // If there are presently no shareholders, so we can start over
        // Any remainder in the earnings per share is rolled forward into
        // the next accrual period.
        c.earnedPerShare.push(
            noShares
                ? 0
                : c.earnedPerShare.head() + c.earnedRewards / totalShares
        );
        c.earnedRewards = noShares ? 0 : c.earnedRewards % totalShares;
    }

    function _updateRedeemable(address rewardAsset, address owner) internal {
        RewardsContainer storage c = containers[rewardAsset];
        uint256 joinedTime = c.joinedAt[owner];
        uint256 balance = balanceOf[owner];
        bool noShares = balance == 0;
        c.redeemableRewards[owner] += noShares
            ? 0
            : (c.earnedPerShare.head() - c.earnedPerShare[joinedTime]) *
                balance;
        c.joinedAt[owner] = c.earnedPerShare.length - 1;
    }

    function _pendingRewards(address rewardAsset, address owner)
        internal
        view
        virtual
        returns (uint256)
    {
        RewardsContainer storage c = containers[rewardAsset];
        uint256 balance = balanceOf[owner];

        if (balance == 0) return c.redeemableRewards[owner];

        uint256 currentEPS = c.earnedPerShare.head() +
            c.earnedRewards /
            totalSupply;

        return
            (currentEPS - c.earnedPerShare[c.joinedAt[owner]]) *
            balance +
            c.redeemableRewards[owner];
    }

    function _claimRewards(
        address owner,
        address rewardAsset,
        uint256 amount
    ) internal virtual {
        RewardsContainer storage c = containers[rewardAsset];
        uint256 rewards = c.redeemableRewards[owner];

        if (rewards < amount) {
            _setRewardsSinceLastCheck(rewardAsset);
            _updateRedeemable(rewardAsset, owner);
            // Value updated by above code
            rewards = c.redeemableRewards[owner];

            // If still insufficient after update, revert.
            if (rewards < amount) {
                revert("Insufficent payable rewards");
            }
        }

        c.redeemableRewards[owner] = rewards - amount;
    }

    /*//////////////////////////////////////////////////////////////
                            ERC4626 OVERRIDES
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual override returns (uint256);
}
