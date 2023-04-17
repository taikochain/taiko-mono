import { configureChains, createClient, type Chain } from '@wagmi/core'
import { publicProvider } from '@wagmi/core/providers/public'
import { jsonRpcProvider } from '@wagmi/core/providers/jsonRpc'
import { CoinbaseWalletConnector } from '@wagmi/core/connectors/coinbaseWallet'
import { WalletConnectConnector } from '@wagmi/core/connectors/walletConnect'
import { MetaMaskConnector } from '@wagmi/core/connectors/metaMask'
import {
  PUBLIC_L1_CHAIN_ID,
  PUBLIC_L1_CHAIN_NAME,
  PUBLIC_L1_RPC,
  PUBLIC_L1_EXPLORER_URL,
  PUBLIC_L2_CHAIN_ID,
  PUBLIC_L2_CHAIN_NAME,
  PUBLIC_L2_RPC,
  PUBLIC_L2_EXPLORER_URL,
} from '$env/static/public'

const chainIdToRpcUrl = {
  [PUBLIC_L1_CHAIN_ID]: PUBLIC_L1_RPC,
  [PUBLIC_L2_CHAIN_ID]: PUBLIC_L2_RPC,
}

const mainnetRpcUrls = { http: [PUBLIC_L1_RPC] }
const taikoRpcUrls = { http: [PUBLIC_L2_RPC] }

const mainnet: Chain = {
  id: parseInt(PUBLIC_L1_CHAIN_ID),
  name: PUBLIC_L1_CHAIN_NAME,
  network: 'Mainnet',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: mainnetRpcUrls,
    public: mainnetRpcUrls,
  },
  blockExplorers: {
    default: {
      name: 'Main',
      url: PUBLIC_L1_EXPLORER_URL,
    },
  },
}

const taiko: Chain = {
  id: parseInt(PUBLIC_L2_CHAIN_ID),
  name: PUBLIC_L2_CHAIN_NAME,
  network: 'Taiko',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: taikoRpcUrls,
    public: taikoRpcUrls,
  },
  blockExplorers: {
    default: {
      name: 'Taiko',
      url: PUBLIC_L2_EXPLORER_URL,
    },
  },
}

const { chains, provider } = configureChains(
  [mainnet, taiko],
  [
    publicProvider(),
    jsonRpcProvider({
      rpc: (chain) => ({ http: chainIdToRpcUrl[chain.id] }),
    }),
  ],
)

const client = createClient({
  provider,
  autoConnect: true,
  connectors: [
    new MetaMaskConnector({ chains }),
    // new CoinbaseWalletConnector({
    //   chains,
    //   options: {
    //     appName: 'Taiko Bridge',
    //   },
    // }),
    // new WalletConnectConnector({
    //   chains,
    //   options: {
    //     projectId: 'Unknown',
    //   },
    // }),
  ],
})

export default client
