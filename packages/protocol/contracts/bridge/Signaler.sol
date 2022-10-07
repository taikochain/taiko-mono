// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "../common/EssentialContract.sol";
import "../common/IHeaderSync.sol";
import "../libs/LibBlockHeader.sol";
import "../libs/LibTrieProof.sol";

struct SignalProof {
    BlockHeader header;
    bytes proof;
}

contract Signaler is EssentialContract {
    using LibBlockHeader for BlockHeader;

    uint256[50] private __gap;

    /// @dev Initializer to be called after being deployed behind a proxy.
    function init(address _addressManager) external initializer {
        EssentialContract._init(_addressManager);
    }

    function sendSignal(bytes32 signal) external {
        bytes32 key = _key(block.chainid, msg.sender, signal);
        assembly {
            sstore(key, 1)
        }
    }

    function isSignalSent(address sender, bytes32 signal)
        public
        view
        returns (bool)
    {
        bytes32 key = _key(block.chainid, sender, signal);
        uint256 v;
        assembly {
            v := sload(key)
        }
        return v == uint256(1);
    }

    function isSignalReceived(
        address sender,
        bytes32 signal,
        uint256 srcChainId,
        bytes calldata proof
    ) public view returns (bool) {
        SignalProof memory mkp = abi.decode(proof, (SignalProof));
        require(srcChainId != block.chainid, "S:chainId");

        address srcSignaler = resolve(srcChainId, "signaler");
        require(srcSignaler != address(0), "S:signaler");

        LibTrieProof.verify(
            mkp.header.stateRoot,
            srcSignaler,
            _key(srcChainId, sender, signal),
            bytes32(uint256(1)),
            mkp.proof
        );

        bytes32 syncedHeaderHash = IHeaderSync(resolve("taiko"))
            .getSyncedHeader(mkp.header.height);

        return
            syncedHeaderHash != 0 &&
            syncedHeaderHash == mkp.header.hashBlockHeader();
    }

    function _key(
        uint256 chainId,
        address sender,
        bytes32 signal
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(chainId, sender, signal));
    }
}
