// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./TrailblazersS1BadgesV6.sol";
import "./BadgeRecruitment.sol";
import "./BadgeRecruitmentV2.sol";

contract TrailblazersBadgesV7 is TrailblazersBadgesV6 {
    /// @notice Updated version function
    /// @return Version string
    function version() external pure virtual override returns (string memory) {
        return "V7";
    }

    /// @notice Modifier to ensure a badge isn't locked on a recruitment for that season
    /// @param tokenId Badge token id
    modifier isNotLockedV7(uint256 tokenId) virtual {
        if (unlockTimestamps[tokenId] > 0 && block.timestamp < season2EndTimestamp) {
            // s2
            revert BADGE_LOCKED();
        } else if (
            unlockTimestamps[tokenId] == season3EndTimestamp
                && block.timestamp > season2EndTimestamp && block.timestamp < season3EndTimestamp
        ) {
            // s3
            revert BADGE_LOCKED_SEASON_2();
        }
        _;
    }

    /// @notice Overwritten update function that prevents locked badges from being transferred
    /// @param to Address to transfer badge to
    /// @param tokenId Badge token id
    /// @param auth Address to authorize transfer
    /// @return Address of the recipient
    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        virtual
        override
        isNotLockedV7(tokenId)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    /// @notice Start recruitment for a badge
    /// @param _badgeId Badge ID
    /// @param _tokenId Token ID
    function startRecruitment(
        uint256 _badgeId,
        uint256 _tokenId
    )
        public
        virtual
        override
        isNotLockedV7(_tokenId)
    {
        if (recruitmentLockDuration == 0) {
            revert RECRUITMENT_LOCK_DURATION_NOT_SET();
        }
        if (ownerOf(_tokenId) != _msgSender()) {
            revert NOT_OWNER();
        }

        if (block.timestamp < season2EndTimestamp) {
            unlockTimestamps[_tokenId] = season2EndTimestamp;
        } else {
            unlockTimestamps[_tokenId] = season3EndTimestamp;
        }

        recruitmentContractV2.startRecruitment(_msgSender(), _badgeId, _tokenId);
    }
}
