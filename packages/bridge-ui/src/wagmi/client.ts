import { type Chain, configureChains, createClient } from '@wagmi/core';
import { publicProvider } from '@wagmi/core/providers/public';
import { jsonRpcProvider } from '@wagmi/core/providers/jsonRpc';
import { CoinbaseWalletConnector } from '@wagmi/core/connectors/coinbaseWallet';
import { WalletConnectConnector } from '@wagmi/core/connectors/walletConnect';
import { MetaMaskConnector } from '@wagmi/core/connectors/metaMask';
import { providers } from '../provider/providers';
import {
  L1_CHAIN_ID,
  L1_CHAIN_NAME,
  L1_EXPLORER_URL,
  L1_RPC,
  L2_CHAIN_ID,
  L2_CHAIN_NAME,
  L2_EXPLORER_URL,
  L2_RPC,
  L3_CHAIN_ID,
  L3_CHAIN_NAME,
  L3_EXPLORER_URL,
  L3_RPC,
} from '../constants/envVars';

export const mainnetWagmiChain: Chain = {
  id: L1_CHAIN_ID,
  name: L1_CHAIN_NAME,
  network: '',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: {
      http: [L1_RPC],
    },
  },
  blockExplorers: {
    default: {
      name: 'Main',
      url: L1_EXPLORER_URL,
    },
  },
};

export const taikoWagmiChain: Chain = {
  id: L2_CHAIN_ID,
  name: L2_CHAIN_NAME,
  network: '',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: {
      http: [L2_RPC],
    },
  },
  blockExplorers: {
    default: {
      name: 'Main',
      url: L2_EXPLORER_URL,
    },
  },
};

export const l3WagmiChain: Chain = {
  id: L3_CHAIN_ID,
  name: L3_CHAIN_NAME,
  network: '',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: {
      http: [L3_RPC],
    },
  },
  blockExplorers: {
    default: {
      name: 'Main',
      url: L3_EXPLORER_URL,
    },
  },
};

const { chains, provider } = configureChains(
  [mainnetWagmiChain, taikoWagmiChain, l3WagmiChain],
  [
    publicProvider(),
    jsonRpcProvider({
      rpc: (chain) => ({
        http: providers[chain.id].connection.url,
      }),
    }),
  ],
);

export const client = createClient({
  autoConnect: true,
  provider,
  connectors: [
    new MetaMaskConnector({ chains }),
    new CoinbaseWalletConnector({
      chains,
      options: { appName: 'Taiko Bridge' },
    }),
    new WalletConnectConnector({
      chains,
      options: { qrcode: true },
    }),
  ],
});
