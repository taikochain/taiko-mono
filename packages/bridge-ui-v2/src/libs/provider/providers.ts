import { JsonRpcProvider } from 'ethers'

import {
  PUBLIC_L1_CHAIN_ID,
  PUBLIC_L1_RPC,
  PUBLIC_L2_CHAIN_ID,
  PUBLIC_L2_RPC,
} from '$env/static/public'

import type { ProvidersRecord } from './types'

export const providers: ProvidersRecord = {
  [PUBLIC_L1_CHAIN_ID]: new JsonRpcProvider(PUBLIC_L1_RPC, PUBLIC_L1_CHAIN_ID),
  [PUBLIC_L2_CHAIN_ID]: new JsonRpcProvider(PUBLIC_L2_RPC, PUBLIC_L2_CHAIN_ID),
}
