import { getContract, type Hash } from '@wagmi/core';
import { UserRejectedRequestError } from 'viem';

import { bridgeABI } from '$abi';
import { bridgeService } from '$config';
import { chainContractsMap } from '$libs/chain';
import { SendMessageError } from '$libs/error';
import { getLogger } from '$libs/util/logger';

import type { Prover } from '../proof/Prover';
import { Bridge } from './Bridge';
import { type ClaimArgs, type ETHBridgeArgs, type Message, MessageStatus, type ReleaseArgs } from './types';

const log = getLogger('bridge:ETHBridge');

export class ETHBridge extends Bridge {
  private static async _prepareTransaction(args: ETHBridgeArgs) {
    const { to, amount, wallet, srcChainId, destChainId, bridgeAddress, processingFee, memo = '' } = args;

    const bridgeContract = getContract({
      walletClient: wallet,
      abi: bridgeABI,
      address: bridgeAddress,
    });

    const owner = wallet.account.address;

    // TODO: contract actually supports bridging to ourselves as well as
    //       to another address at the same time
    const [depositValue, callValue] =
      to.toLowerCase() === owner.toLowerCase() ? [amount, BigInt(0)] : [BigInt(0), amount];

    // If there is a processing fee, use the specified message gas limit
    // as might not be called by the owner
    const gasLimit = processingFee > 0 ? bridgeService.noOwnerGasLimit : BigInt(0);

    const message: Message = {
      to,
      owner,
      sender: owner,
      refundAddress: owner,

      srcChainId: BigInt(srcChainId),
      destChainId: BigInt(destChainId),

      gasLimit,
      callValue,
      depositValue,
      processingFee,

      memo,
      data: '0x',
      id: BigInt(0), // will be set in contract
    };

    log('Preparing transaction with message', message);

    return { bridgeContract, message };
  }

  constructor(prover: Prover) {
    super(prover);
  }

  async estimateGas(args: ETHBridgeArgs) {
    const { bridgeContract, message } = await ETHBridge._prepareTransaction(args);
    const { depositValue, callValue, processingFee } = message;

    const value = depositValue + callValue + processingFee;

    log('Estimating gas for sendMessage call with value', value);

    const estimatedGas = await bridgeContract.estimateGas.sendMessage([message], { value });

    log('Gas estimated', estimatedGas);

    return estimatedGas;
  }

  async bridge(args: ETHBridgeArgs) {
    const { bridgeContract, message } = await ETHBridge._prepareTransaction(args);
    const { depositValue, callValue, processingFee } = message;

    const value = depositValue + callValue + processingFee;

    try {
      log('Calling sendMessage with value', value);

      const txHash = await bridgeContract.write.sendMessage([message], { value });

      log('Transaction hash for sendMessage call', txHash);

      return txHash;
    } catch (err) {
      console.error(err);

      if (`${err}`.includes('denied transaction signature')) {
        throw new UserRejectedRequestError(err as Error);
      }

      throw new SendMessageError('failed to bridge ETH', { cause: err });
    }
  }

  async claim(args: ClaimArgs) {
    const { messageStatus, destBridgeContract } = await super.beforeClaiming(args);

    let txHash: Hash;
    const { msgHash, message } = args;
    const srcChainId = Number(message.srcChainId);
    const destChainId = Number(message.destChainId);

    if (messageStatus === MessageStatus.NEW) {
      const proof = await this._prover.generateProofToClaim(msgHash, srcChainId, destChainId);

      txHash = await destBridgeContract.write.processMessage([message, proof]);

      log('Transaction hash for processMessage call', txHash);

      // TODO: possibly handle unpredictable gas limit error
      //       by trying with a higher gas limit
    } else {
      // MessageStatus.RETRIABLE
      log('Retrying message', message);

      // Last attempt to send the message: isLastAttempt = true
      txHash = await destBridgeContract.write.retryMessage([message, true]);

      log('Transaction hash for retryMessage call', txHash);
    }

    return txHash;
  }

  async release(args: ReleaseArgs) {
    await super.beforeReleasing(args);

    const { msgHash, message, wallet } = args;
    const srcChainId = Number(message.srcChainId);
    const destChainId = Number(message.destChainId);

    const proof = await this._prover.generateProofToRelease(msgHash, srcChainId, destChainId);

    const srcBridgeAddress = chainContractsMap[wallet.chain.id].bridgeAddress;
    const srcBridgeContract = getContract({
      walletClient: wallet,
      abi: bridgeABI,
      address: srcBridgeAddress,
    });

    const txHash = await srcBridgeContract.write.releaseEther([message, proof]);

    log('Transaction hash for releaseEther call', txHash);

    // TODO: possibly handle unpredictable gas limit error
    //       by trying with a higher gas limit

    return txHash;
  }
}
