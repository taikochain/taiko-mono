import { readContract } from '@wagmi/core';

import { taikoonTokenAbi, taikoonTokenAddress } from '../../generated/abi/';
import getConfig from '../../lib/wagmi/getConfig';

export async function tokenURI(tokenId: number): Promise<string> {
  const { config, chainId } = getConfig();
  console.warn('calling TokenURI!');
  const result = await readContract(config, {
    abi: taikoonTokenAbi,
    address: taikoonTokenAddress[chainId],
    functionName: 'tokenURI',
    args: [BigInt(tokenId)],
    chainId,
  });

  return result as string;
}
