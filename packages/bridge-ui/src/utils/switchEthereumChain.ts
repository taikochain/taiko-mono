import type { Ethereum } from "@wagmi/core";
import { BigNumber, ethers } from "ethers";
import type { Chain } from "../domain/chain";

export const switchEthereumChain = async (ethereum: Ethereum, chain: Chain) => {
  try {
    await ethereum.request({
      method: "wallet_switchEthereumChain",
      params: [{ chainId: ethers.utils.hexValue(chain.id) }],
    });
  } catch (switchError) {
    // This error code indicates that the chain has not been added to MetaMask.
    if (switchError.code === 4902) {
      try {
        await ethereum.request({
          method: "wallet_addEthereumChain",
          params: [
            {
              chainId: ethers.utils.hexValue(chain.id),
              chainName: chain.name,
              rpcUrls: [chain.rpc],
            },
          ],
        });
      } catch (addError) {
        throw addError;
      }
    }
  }
};
