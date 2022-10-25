import { BigNumber, ethers } from "ethers";
import type { Transaction } from "ethers";
import type { ApproveOpts, Bridge, BridgeOpts } from "../domain/bridge";
import logger from "../utils/logger";
import BRIDGE_ABI from "../constants/BRIDGE_ABI";

class ETHBridge implements Bridge {
  constructor() {}

  async Allowance(opts: ApproveOpts): Promise<BigNumber> {
    return new Promise((resolve) =>
      resolve(BigNumber.from(100000000000000000000))
    );
  }

  async Approve(opts: ApproveOpts): Promise<Transaction> {
    return {} as any as Transaction;
  }

  async Bridge(opts: BridgeOpts): Promise<Transaction> {
    logger.log("ETHBridge::Bridge::opts", opts);
    const bridge = new ethers.Contract(
      opts.bridgeAddress,
      BRIDGE_ABI,
      opts.signer
    );

    const isDestChainEnabled = await bridge.isDestChainEnabled(
      opts.destChainId
    );
    if (!isDestChainEnabled)
      await bridge.enableDestChain(opts.destChainId, true);

    const owner = await opts.signer.getAddress();

    const message = {
      id: 1, // to be set by contract
      sender: owner,
      srcChainId: await opts.signer.getChainId(),
      destChainId: opts.destChainId,
      owner: owner,
      to: owner,
      refundAddress: owner,
      depositValue: opts.amount,
      callValue: 1,
      processingFee: 1,
      gasLimit: 10000,
      data: ethers.constants.HashZero,
      memo: "",
    };

    const expectedAmount = BigNumber.from(message.depositValue)
      .add(message.callValue)
      .add(message.processingFee);

    logger.log("ETHBridge::sendingMessage", message);
    return await bridge.sendMessage(message, {
      value: expectedAmount,
    });
  }
}

export { ETHBridge };
