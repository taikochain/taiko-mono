import type { Address } from 'viem';

import { relayerApiServices } from '$libs/relayer';
import { bridgeTxService } from '$libs/storage';
import { getLogger } from '$libs/util/logger';
import { mergeAndCaptureOutdatedTransactions } from '$libs/util/mergeTransactions';

import type { BridgeTransaction } from './types';

const log = getLogger('bridge:fetchTransactions');

export async function fetchTransactions(userAddress: Address) {
  // Transactions from local storage
  const localTxs: BridgeTransaction[] = await bridgeTxService.getAllTxByAddress(userAddress);

  // Get all transactions from all relayers
  const relayerTxPromises: Promise<BridgeTransaction[]>[] = relayerApiServices.map(async (relayerApiService) => {
    const { txs } = await relayerApiService.getAllBridgeTransactionByAddress(userAddress, {
      page: 0,
      size: 100,
    });
    log(`fetched ${txs.length} transactions from relayer`, txs);
    return txs;
  });

  // Wait for all promises to resolve
  const relayerTxsArrays: BridgeTransaction[][] = await Promise.all(relayerTxPromises);

  // Flatten the arrays into a single array
  const relayerTxs: BridgeTransaction[] = relayerTxsArrays.reduce((acc, txs) => acc.concat(txs), []);

  log(`fetched ${relayerTxs.length} transactions from all relayers`, relayerTxs);

  const { mergedTransactions, outdatedLocalTransactions } = mergeAndCaptureOutdatedTransactions(localTxs, relayerTxs);
  if (outdatedLocalTransactions.length > 0) {
    log(
      `found ${outdatedLocalTransactions.length} outdated transaction(s)`,
      outdatedLocalTransactions.map((tx) => tx.hash),
    );
  }

  return { mergedTransactions, outdatedLocalTransactions };
}
