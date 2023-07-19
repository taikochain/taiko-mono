// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { IERC165 } from
    "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC721Receiver } from
    "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC721Upgradeable } from
    "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import { ERC721Upgradeable } from
    "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { Create2Upgradeable } from
    "@openzeppelin/contracts-upgradeable/utils/Create2Upgradeable.sol";
import { IBridge } from "../bridge/IBridge.sol";
import { BaseNFTVault } from "./BaseNFTVault.sol";
import { BridgedERC721 } from "./BridgedERC721.sol";
import { Proxied } from "../common/Proxied.sol";

/**
 * This vault holds all ERC721 tokens that users have deposited.
 * It also manages the mapping between canonical tokens and their bridged
 * tokens.
 */
contract ERC721Vault is BaseNFTVault, IERC721Receiver {
    /**
     * Transfers ERC721 tokens to this vault and sends a message to the
     * destination chain so the user can receive the same (bridged) tokens
     * by invoking the message call.
     *
     * @param opt Option for sending the ERC721 token.
     */
    function sendToken(BridgeTransferOp calldata opt)
        external
        payable
        nonReentrant
        onlyValidAddresses(opt.destChainId, "erc721_vault", opt.to, opt.token)
        onlyValidAmounts(opt.amounts, opt.tokenIds, true)
    {
        if (
            !IERC165(opt.token).supportsInterface(ERC721_INTERFACE_ID)
                || IERC165(opt.token).supportsInterface(ERC1155_INTERFACE_ID)
        ) {
            revert VAULT_INTERFACE_NOT_SUPPORTED();
        }

        // We need to save them into memory - because structs containing
        // dynamic arrays will cause stack-too-deep error when passed
        uint256[] memory _amounts = opt.amounts;
        address _token = opt.token;
        uint256[] memory _tokenIds = opt.tokenIds;

        IBridge.Message memory message;
        message.destChainId = opt.destChainId;
        message.data = _sendToken(msg.sender, opt);
        message.owner = msg.sender;
        message.to = resolve(message.destChainId, "erc721_vault", false);
        message.gasLimit = opt.gasLimit;
        message.processingFee = opt.processingFee;
        message.refundAddress = opt.refundAddress;
        message.memo = opt.memo;

        bytes32 msgHash = IBridge(resolve("bridge", false)).sendMessage{
            value: msg.value
        }(message);

        emit TokenSent({
            msgHash: msgHash,
            from: message.owner,
            to: opt.to,
            destChainId: message.destChainId,
            token: _token,
            tokenIds: _tokenIds,
            amounts: _amounts
        });
    }

    /**
     * @dev This function can only be called by the bridge contract while
     * invoking a message call. See sendToken, which sets the data to invoke
     * this function.
     * @param ctoken The ctoken ERC721 token which may or may not
     * live on this chain. If not, a BridgedERC721 contract will be
     * deployed.
     * @param from The source address.
     * @param to The destination address.
     * @param tokenIds The tokenId array to be sent.
     */
    function receiveToken(
        CanonicalNFT calldata ctoken,
        address from,
        address to,
        uint256[] memory tokenIds
    )
        external
        nonReentrant
        onlyFromNamed("bridge")
    {
        IBridge.Context memory ctx = _checkValidContext("erc721_vault");
        address token;

        if (ctoken.chainId == block.chainid) {
            token = ctoken.addr;
            for (uint256 i; i < tokenIds.length; i++) {
                ERC721Upgradeable(token).transferFrom(
                    address(this), to, tokenIds[i]
                );
            }
        } else {
            token = _getOrDeployBridgedToken(ctoken);

            for (uint256 i; i < tokenIds.length; ++i) {
                BridgedERC721(token).mint(to, tokenIds[i]);
            }
        }

        emit TokenReceived({
            msgHash: ctx.msgHash,
            from: from,
            to: to,
            srcChainId: ctx.srcChainId,
            token: token,
            tokenIds: tokenIds,
            amounts: new uint256[](0)
        });
    }

    function releaseToken(
        IBridge.Message calldata message,
        bytes calldata proof
    )
        external
        nonReentrant
    {
        if (message.owner == address(0)) revert VAULT_INVALID_OWNER();
        if (message.srcChainId != block.chainid) {
            revert VAULT_INVALID_SRC_CHAIN_ID();
        }

        (
            CanonicalNFT memory nft, //
            ,
            ,
            uint256[] memory tokenIds
        ) = decodeMessageData(message.data);

        bytes32 msgHash = hashAndMarkMsgReleased(message, proof, nft.addr);

        if (isBridgedToken[nft.addr]) {
            for (uint256 i; i < tokenIds.length; i++) {
                BridgedERC721(nft.addr).mint(message.owner, tokenIds[i]);
            }
        } else {
            for (uint256 i; i < tokenIds.length; i++) {
                IERC721Upgradeable(nft.addr).safeTransferFrom(
                    address(this), message.owner, tokenIds[i]
                );
            }
        }

        emit TokenReleased({
            msgHash: msgHash,
            from: message.owner,
            token: nft.addr,
            tokenIds: tokenIds,
            amounts: new uint256[](0)
        });
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    )
        external
        pure
        returns (bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * Decodes the data which was abi.encodeWithSelector() encoded.
     * @param dataWithSelector Data encoded with abi.encodedWithSelector
     * @return nft CanonicalNFT data
     * @return owner Owner of the message
     * @return to The to address messages sent to
     * @return tokenIds The tokenIds
     */
    function decodeMessageData(bytes memory dataWithSelector)
        public
        pure
        returns (
            CanonicalNFT memory nft,
            address owner,
            address to,
            uint256[] memory tokenIds
        )
    {
        return abi.decode(
            _extractCalldata(dataWithSelector),
            (CanonicalNFT, address, address, uint256[])
        );
    }

    function _sendToken(
        address owner,
        BridgeTransferOp calldata opt
    )
        private
        returns (bytes memory)
    {
        bool isBridgedToken = isBridgedToken[opt.token];
        CanonicalNFT memory nft = bridgedToCanonical[opt.token];

        // is a btoken, meaning, it does not live on this chain
        if (isBridgedToken) {
            for (uint256 i; i < opt.tokenIds.length; i++) {
                BridgedERC721(opt.token).burn(owner, opt.tokenIds[i]);
            }
        } else {
            // is a ctoken token, meaning, it lives on this chain
            ERC721Upgradeable t = ERC721Upgradeable(opt.token);

            nft = CanonicalNFT({
                chainId: block.chainid,
                addr: opt.token,
                symbol: ERC721Upgradeable(t).symbol(),
                name: ERC721Upgradeable(t).name()
            });

            for (uint256 i; i < opt.tokenIds.length; i++) {
                t.transferFrom(owner, address(this), opt.tokenIds[i]);
            }
        }

        return abi.encodeWithSelector(
            ERC721Vault.receiveToken.selector, nft, owner, opt.to, opt.tokenIds
        );
    }

    function _getOrDeployBridgedToken(CanonicalNFT calldata ctoken)
        private
        returns (address btoken)
    {
        btoken = canonicalToBridged[ctoken.chainId][ctoken.addr];

        if (btoken == address(0)) {
            btoken = _deployBridgedToken(ctoken);
        }
    }

    /**
     * @dev Deploys a new BridgedNFT contract and initializes it. This must be
     * called before the first time a btoken is sent to this chain.
     */
    function _deployBridgedToken(CanonicalNFT memory ctoken)
        private
        returns (address btoken)
    {
        btoken = Create2Upgradeable.deploy({
            amount: 0, // amount of Ether to send
            salt: keccak256(
                bytes.concat(
                    bytes32(ctoken.chainId), bytes32(uint256(uint160(ctoken.addr)))
                )
                ),
            bytecode: type(BridgedERC721).creationCode
        });

        BridgedERC721(payable(btoken)).init({
            _addressManager: address(_addressManager),
            _srcToken: ctoken.addr,
            _srcChainId: ctoken.chainId,
            _symbol: ctoken.symbol,
            _name: ctoken.name
        });

        isBridgedToken[btoken] = true;
        bridgedToCanonical[btoken] = ctoken;
        canonicalToBridged[ctoken.chainId][ctoken.addr] = btoken;

        emit BridgedTokenDeployed({
            chainId: ctoken.chainId,
            ctoken: ctoken.addr,
            btoken: btoken,
            ctokenSymbol: ctoken.symbol,
            ctokenName: ctoken.name
        });
    }
}

contract ProxiedERC721Vault is Proxied, ERC721Vault { }
