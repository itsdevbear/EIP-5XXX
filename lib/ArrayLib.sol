// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.14;

library ArrayLib {
    function head(uint256[] storage arr) internal view returns (uint256) {
        return arr[arr.length - 1];
    }
}
