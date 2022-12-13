import { BigNumber, BigNumberish, ethers } from "ethers";
import { TKO } from "../domain/token";
import { CHAIN_MAINNET, CHAIN_TKO } from "../domain/chain";
import { MessageStatus } from "../domain/message";
import { StorageService } from "./service";
const mockStorage = {
  getItem: jest.fn(),
};

const mockProvider = {
  getTransactionReceipt: jest.fn(),
};

const mockContract = {
  queryFilter: jest.fn(),
  getMessageStatus: jest.fn(),
  symbol: jest.fn(),
};

jest.mock("ethers", () => ({
  /* eslint-disable-next-line */
  ...(jest.requireActual("ethers") as object),
  Contract: function () {
    return mockContract;
  },
}));

const providerMap: Map<number, ethers.providers.JsonRpcProvider> = new Map<
  number,
  ethers.providers.JsonRpcProvider
>();

providerMap.set(
  CHAIN_MAINNET.id,
  mockProvider as unknown as ethers.providers.JsonRpcProvider
);
providerMap.set(
  CHAIN_TKO.id,
  mockProvider as unknown as ethers.providers.JsonRpcProvider
);

const mockTx: ethers.Transaction = {
  chainId: CHAIN_MAINNET.id,
  hash: "0x123",
  nonce: 0,
  gasLimit: BigNumber.from(1),
  data: "0x",
  value: BigNumber.from(1),
};

const mockTxs: ethers.Transaction[] = [mockTx];

const mockTxReceipt = {
  blockNumber: 1,
};

const mockEvent = {
  args: {
    message: {
      owner: "0x123",
    },
    signal: "0x456",
  },
};

const mockErc20Event = {
  args: {
    amount: "100",
    signal: "0x456",
  },
};

const mockQuery = [mockEvent];

const mockErc20Query = [mockErc20Event];

jest.mock("../store/bridge", () => ({
  chainIdToBridgeAddress: jest.fn(),
}));

jest.mock("svelte/store", () => ({
  get: function () {
    return {
      get: jest.fn(),
    };
  },
}));

describe("storage tests", () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });

  it("gets all transactions by address, no transactions in list", async () => {
    mockStorage.getItem.mockImplementation(() => {
      return "[]";
    });

    mockContract.symbol.mockImplementation(() => {
      return TKO.symbol;
    });

    const svc = new StorageService(mockStorage as any, providerMap);

    const addresses = await svc.GetAllByAddress("0x123", 167001);

    expect(addresses).toEqual([]);
  });

  it("gets all transactions by address, no receipt", async () => {
    mockStorage.getItem.mockImplementation(() => {
      return JSON.stringify(mockTxs);
    });

    mockContract.getMessageStatus.mockImplementation(() => {
      return MessageStatus.New;
    });

    mockContract.queryFilter.mockImplementation(() => {
      return mockQuery;
    });

    mockContract.symbol.mockImplementation(() => {
      return TKO.symbol;
    });

    const svc = new StorageService(mockStorage as any, providerMap);

    const addresses = await svc.GetAllByAddress("0x123", CHAIN_MAINNET.id);

    expect(addresses).toEqual([]);
  });

  it("gets all transactions by address, no event", async () => {
    mockStorage.getItem.mockImplementation(() => {
      return JSON.stringify(mockTxs);
    });

    mockProvider.getTransactionReceipt.mockImplementation(() => {
      return mockTxReceipt;
    });

    mockContract.getMessageStatus.mockImplementation(() => {
      return MessageStatus.New;
    });

    mockContract.queryFilter.mockImplementation(() => {
      return [];
    });

    mockContract.symbol.mockImplementation(() => {
      return TKO.symbol;
    });

    const svc = new StorageService(mockStorage as any, providerMap);

    const addresses = await svc.GetAllByAddress("0x123", CHAIN_MAINNET.id);

    expect(addresses).toEqual([]);
  });

  it("gets all transactions by address", async () => {
    mockStorage.getItem.mockImplementation(() => {
      return JSON.stringify(mockTxs);
    });

    mockProvider.getTransactionReceipt.mockImplementation(() => {
      return mockTxReceipt;
    });

    mockContract.getMessageStatus.mockImplementation(() => {
      return MessageStatus.New;
    });

    mockContract.queryFilter.mockImplementation(
      (name: string, from: BigNumberish, to: BigNumberish) => {
        if (name === "ERC20Sent") {
          return mockErc20Query;
        }

        return mockQuery;
      }
    );

    mockContract.symbol.mockImplementation(() => {
      return TKO.symbol;
    });

    const svc = new StorageService(mockStorage as any, providerMap);

    const addresses = await svc.GetAllByAddress("0x123", CHAIN_MAINNET.id);

    expect(addresses).toEqual([
      {
        amountInWei: BigNumber.from(0x64),
        ethersTx: {
          chainId: CHAIN_MAINNET.id,
          data: "0x",
          gasLimit: {
            hex: "0x01",
            type: "BigNumber",
          },
          hash: "0x123",
          nonce: 0,
          value: {
            hex: "0x01",
            type: "BigNumber",
          },
        },
        message: {
          owner: "0x123",
        },
        receipt: {
          blockNumber: 1,
        },
        signal: "0x456",
        status: 0,

        symbol: "TKO",
      },
    ]);
  });

  it("gets all transactions by address, CHAIN_TKO", async () => {
    mockTx.chainId = CHAIN_TKO.id;
    mockStorage.getItem.mockImplementation(() => {
      return JSON.stringify(mockTxs);
    });

    mockProvider.getTransactionReceipt.mockImplementation(() => {
      return mockTxReceipt;
    });

    mockContract.getMessageStatus.mockImplementation(() => {
      return MessageStatus.New;
    });

    mockContract.queryFilter.mockImplementation(
      (name: string, from: BigNumberish, to: BigNumberish) => {
        if (name === "ERC20Sent") {
          return mockErc20Query;
        }

        return mockQuery;
      }
    );

    mockContract.symbol.mockImplementation(() => {
      return TKO.symbol;
    });

    const svc = new StorageService(mockStorage as any, providerMap);

    const addresses = await svc.GetAllByAddress("0x123", CHAIN_TKO.id);

    expect(addresses).toEqual([
      {
        amountInWei: BigNumber.from(0x64),
        ethersTx: {
          chainId: CHAIN_TKO.id,
          data: "0x",
          gasLimit: {
            hex: "0x01",
            type: "BigNumber",
          },
          hash: "0x123",
          nonce: 0,
          value: {
            hex: "0x01",
            type: "BigNumber",
          },
        },
        message: {
          owner: "0x123",
        },
        receipt: {
          blockNumber: 1,
        },
        signal: "0x456",
        status: 0,
        symbol: "TKO",
      },
    ]);
  });
});
