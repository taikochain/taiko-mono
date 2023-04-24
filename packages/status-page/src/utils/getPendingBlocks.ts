import { Contract, ethers } from "ethers";
import TaikoL1 from "../constants/abi/TaikoL1";

export const getPendingBlocks = async (
  provider: ethers.providers.JsonRpcProvider,
  contractAddress: string
): Promise<number> => {
  const contract: Contract = new Contract(contractAddress, TaikoL1, provider);
  const stateVariables = await contract.getStateVariables();
  const nextBlockId = stateVariables.numBlocks;
  const lastBlockId = stateVariables.lastVerifiedBlockId;
  return nextBlockId - lastBlockId - 1;
};
