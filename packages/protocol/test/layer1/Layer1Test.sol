// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/layer1/based/TaikoInbox.sol";
import "src/layer1/token/TaikoToken.sol";
import "src/layer1/verifiers/SgxVerifier.sol";
import "src/layer1/verifiers/SP1Verifier.sol";
import "src/layer1/verifiers/Risc0Verifier.sol";
import "src/layer1/team/ERC20Airdrop.sol";
import "src/shared/bridge/QuotaManager.sol";
import "src/shared/bridge/Bridge.sol";
import "src/layer1/preconf/mvp/PreconfWhitelist.sol";
import "src/layer1/preconf/mvp/PreconfTaskManager.sol";
import "test/shared/CommonTest.sol";

contract ConfigurableInbox is TaikoInbox {
    ITaikoInbox.Config private __config;

    function initWithConfig(
        address _owner,
        address _rollupResolver,
        bytes32 _genesisBlockHash,
        ITaikoInbox.Config memory _config
    )
        external
        initializer
    {
        __Taiko_init(_owner, _rollupResolver, _genesisBlockHash);
        __config = _config;
    }

    function getConfig() public view override returns (ITaikoInbox.Config memory) {
        return __config;
    }

    function _calcTxListHash(uint8, uint8) internal pure override returns (bytes32) {
        return keccak256("BLOB");
    }
}

abstract contract Layer1Test is CommonTest {
    function deployInbox(
        bytes32 _genesisBlockHash,
        ITaikoInbox.Config memory _config
    )
        internal
        returns (TaikoInbox)
    {
        return TaikoInbox(
            deploy({
                name: "taiko",
                impl: address(new ConfigurableInbox()),
                data: abi.encodeCall(
                    ConfigurableInbox.initWithConfig,
                    (address(0), address(resolver), _genesisBlockHash, _config)
                    )
            })
        );
    }

    function deployWhitelist() internal returns (PreconfWhitelist) {
        return PreconfWhitelist(
            deploy({
                name: "preconf_whitelist",
                impl: address(new PreconfWhitelist()),
                data: abi.encodeCall(PreconfWhitelist.init, address(0))
            })
        );
    }

    function deployPreconfTaskManager() internal returns (PreconfTaskManager) {
        return PreconfTaskManager(
            deploy({
                name: "preconf_router",
                impl: address(new PreconfTaskManager()),
                data: abi.encodeCall(PreconfTaskManager.init, address(0), address(resolver))
            })
        );
    }

    function deployBondToken() internal returns (TaikoToken) {
        return TaikoToken(
            deploy({
                name: "bond_token",
                impl: address(new TaikoToken()),
                data: abi.encodeCall(TaikoToken.init, (address(0), address(this)))
            })
        );
    }

    function deploySgxVerifier() internal returns (SgxVerifier) {
        return SgxVerifier(
            deploy({
                name: "tier_sgx",
                impl: address(new SgxVerifier(taikoChainId)),
                data: abi.encodeCall(SgxVerifier.init, (address(0), address(resolver)))
            })
        );
    }
}
