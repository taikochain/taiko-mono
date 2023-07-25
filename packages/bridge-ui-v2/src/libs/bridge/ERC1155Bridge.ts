import type { Hash, Hex } from 'viem';

import type { Bridge } from './types';

export class ERC1155Bridge implements Bridge {
  async estimateGas(): Promise<bigint> {
    return Promise.resolve(BigInt(0));
  }

  async bridge(): Promise<Hex> {
    return Promise.resolve('0x');
  }

  async claim() {
    return Promise.resolve('0x' as Hash);
  }

  async release() {
    return Promise.resolve('0x' as Hash);
  }
}
