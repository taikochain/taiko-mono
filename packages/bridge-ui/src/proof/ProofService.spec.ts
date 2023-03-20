import { BigNumber, ethers } from 'ethers';
import type { EthGetProofResponse } from '../domain/proof';
import { ProofService } from './ProofService';

const mockProvider = {
  send: jest.fn(),
};

const mockContract = {
  getLatestSyncedHeader: jest.fn(),
};

jest.mock('ethers', () => ({
  /* eslint-disable-next-line */
  ...(jest.requireActual('ethers') as object),
  Contract: function () {
    return mockContract;
  },
}));

const block = {
  parentHash:
    '0xa7881266ca0a344c43cb24175d9dbd243b58d45d6ae6ad71310a273a3d1d3afb',
  sha3Uncles:
    '0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347',
  miner: '0xea674fdde714fd979de3edf0f56aa9716b898ec8',
  stateRoot:
    '0xc0dcf937b3f6136dd70a1ad11cc57b040fd410f3c49a5146f20c732895a3cc21',
  transactionsRoot:
    '0x7273ade6b6ed865a9975ac281da23b90b141a8b607d874d2cd95e65e81336f8e',
  receiptsRoot:
    '0x74bb61e381e9238a08b169580f3cbf9b8b79d7d5ee708d3e286103eb291dfd08',
  logsBloom:
    '0x00000000000400000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000020000000000000000000000000000000000000000000000000100000000008000000000000000000000000',
  difficulty: 123,
  number: 123,
  gasLimit: 123,
  gasUsed: 123,
  timestamp: 123,
  extraData: '0x65746865726d696e652d75732d7765737431',
  mixHash: '0xf5ba25df1e92e89a09e0b32063b81795f631100801158f5fa733f2ba26843bd0',
  nonce: 123,
  baseFeePerGas: '0',
  withdrawalsRoot: ethers.constants.HashZero,
};

const storageProof: EthGetProofResponse = {
  balance: '',
  nonce: '',
  codeHash: '',
  storageHash: '',
  accountProof: [],
  storageProof: [
    {
      key: '0x01',
      value: '0x1',
      proof: [ethers.constants.HashZero],
    },
  ],
};

const invalidStorageProof: EthGetProofResponse = {
  balance: '',
  nonce: '',
  codeHash: '',
  storageHash: '',
  accountProof: [],
  storageProof: [
    {
      key: '0x01',
      value: '0x0',
      proof: [ethers.constants.HashZero],
    },
  ],
};

const storageProof2: EthGetProofResponse = {
  balance: '',
  nonce: '',
  codeHash: '',
  storageHash: '',
  accountProof: [],
  storageProof: [
    {
      key: '0x01',
      value: '0x3',
      proof: [ethers.constants.HashZero],
    },
  ],
};

const invalidStorageProof2: EthGetProofResponse = {
  balance: '',
  nonce: '',
  codeHash: '',
  storageHash: '',
  accountProof: [],
  storageProof: [
    {
      key: '0x01',
      value: '0x0',
      proof: [ethers.constants.HashZero],
    },
  ],
};

const expectedProof =
  '0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000380a7881266ca0a344c43cb24175d9dbd243b58d45d6ae6ad71310a273a3d1d3afb1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347000000000000000000000000ea674fdde714fd979de3edf0f56aa9716b898ec8c0dcf937b3f6136dd70a1ad11cc57b040fd410f3c49a5146f20c732895a3cc217273ade6b6ed865a9975ac281da23b90b141a8b607d874d2cd95e65e81336f8e74bb61e381e9238a08b169580f3cbf9b8b79d7d5ee708d3e286103eb291dfd0800000000000400000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000020000000000000000000000000000000000000000000000000100000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000000000007b0000000000000000000000000000000000000000000000000000000000000300f5ba25df1e92e89a09e0b32063b81795f631100801158f5fa733f2ba26843bd0000000000000000000000000000000000000000000000000000000000000007b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001265746865726d696e652d75732d7765737431000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022e1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

const expectedProofWithBaseFee =
  '0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000380a7881266ca0a344c43cb24175d9dbd243b58d45d6ae6ad71310a273a3d1d3afb1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347000000000000000000000000ea674fdde714fd979de3edf0f56aa9716b898ec8c0dcf937b3f6136dd70a1ad11cc57b040fd410f3c49a5146f20c732895a3cc217273ade6b6ed865a9975ac281da23b90b141a8b607d874d2cd95e65e81336f8e74bb61e381e9238a08b169580f3cbf9b8b79d7d5ee708d3e286103eb291dfd0800000000000400000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000020000000000000000000000000000000000000000000000000100000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000000000007b0000000000000000000000000000000000000000000000000000000000000300f5ba25df1e92e89a09e0b32063b81795f631100801158f5fa733f2ba26843bd0000000000000000000000000000000000000000000000000000000000000007b00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001265746865726d696e652d75732d7765737431000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022e1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';

const srcChain = 167001;
const destChain = 31336;

const map = new Map<number, ethers.providers.JsonRpcProvider>();
map.set(srcChain, mockProvider as unknown as ethers.providers.JsonRpcProvider);
map.set(destChain, mockProvider as unknown as ethers.providers.JsonRpcProvider);

describe('prover tests', () => {
  beforeEach(() => {
    jest.resetAllMocks();
    block.baseFeePerGas = '0';
  });

  it('throws on invalid proof', async () => {
    mockProvider.send.mockImplementation(
      (method: string, params: unknown[]) => {
        if (method === 'eth_getBlockByHash') {
          return block;
        }

        if (method === 'eth_getProof') {
          return invalidStorageProof;
        }
      },
    );

    const prover: ProofService = new ProofService(map);

    await expect(
      prover.GenerateProof({
        msgHash: ethers.constants.HashZero,
        sender: ethers.constants.AddressZero,
        srcBridgeAddress: ethers.constants.AddressZero,
        srcChain: srcChain,
        destChain: destChain,
        destHeaderSyncAddress: ethers.constants.AddressZero,
        srcSignalServiceAddress: ethers.constants.AddressZero,
      }),
    ).rejects.toThrowError('invalid proof');
  });

  it('generates proof', async () => {
    mockProvider.send.mockImplementation(
      (method: string, params: unknown[]) => {
        if (method === 'eth_getBlockByHash') {
          return block;
        }

        if (method === 'eth_getProof') {
          return storageProof;
        }
      },
    );

    const prover: ProofService = new ProofService(map);

    const proof = await prover.GenerateProof({
      msgHash: ethers.constants.HashZero,
      sender: ethers.constants.AddressZero,
      srcBridgeAddress: ethers.constants.AddressZero,
      srcChain: srcChain,
      destChain: destChain,
      destHeaderSyncAddress: ethers.constants.AddressZero,
      srcSignalServiceAddress: ethers.constants.AddressZero,
    });
    expect(proof).toBe(expectedProof);
  });

  it('generates proof with baseFeePerGas set', async () => {
    mockProvider.send.mockImplementation(
      (method: string, params: unknown[]) => {
        if (method === 'eth_getBlockByHash') {
          return block;
        }

        if (method === 'eth_getProof') {
          return storageProof;
        }
      },
    );

    block.baseFeePerGas = '1';

    const prover: ProofService = new ProofService(map);

    const proof = await prover.GenerateProof({
      msgHash: ethers.constants.HashZero,
      sender: ethers.constants.AddressZero,
      srcBridgeAddress: ethers.constants.AddressZero,
      srcChain: srcChain,
      destChain: destChain,
      destHeaderSyncAddress: ethers.constants.AddressZero,
      srcSignalServiceAddress: ethers.constants.AddressZero,
    });
    expect(proof).toBe(expectedProofWithBaseFee);
  });
});

describe('generate release proof tests', () => {
  beforeEach(() => {
    jest.resetAllMocks();
    block.baseFeePerGas = '0';
  });

  it('throws on invalid proof', async () => {
    mockProvider.send.mockImplementation(
      (method: string, params: unknown[]) => {
        if (method === 'eth_getBlockByHash') {
          return block;
        }

        if (method === 'eth_getProof') {
          return invalidStorageProof2;
        }
      },
    );

    const prover: ProofService = new ProofService(map);

    await expect(
      prover.GenerateReleaseProof({
        msgHash: ethers.constants.HashZero,
        sender: ethers.constants.AddressZero,
        destBridgeAddress: ethers.constants.AddressZero,
        srcChain: srcChain,
        destChain: destChain,
        destHeaderSyncAddress: ethers.constants.AddressZero,
        srcHeaderSyncAddress: ethers.constants.AddressZero,
      }),
    ).rejects.toThrowError('invalid proof');
  });

  it('generates proof', async () => {
    mockProvider.send.mockImplementation(
      (method: string, params: unknown[]) => {
        if (method === 'eth_getBlockByHash') {
          return block;
        }

        if (method === 'eth_getProof') {
          return storageProof2;
        }
      },
    );

    const prover: ProofService = new ProofService(map);

    const proof = await prover.GenerateReleaseProof({
      msgHash: ethers.constants.HashZero,
      sender: ethers.constants.AddressZero,
      destBridgeAddress: ethers.constants.AddressZero,
      srcChain: srcChain,
      destChain: destChain,
      destHeaderSyncAddress: ethers.constants.AddressZero,
      srcHeaderSyncAddress: ethers.constants.AddressZero,
    });
    expect(proof).toBe(expectedProof);
  });

  it('generates proof with baseFeePerGas set', async () => {
    mockProvider.send.mockImplementation(
      (method: string, params: unknown[]) => {
        if (method === 'eth_getBlockByHash') {
          return block;
        }

        if (method === 'eth_getProof') {
          return storageProof2;
        }
      },
    );

    block.baseFeePerGas = '1';

    const prover: ProofService = new ProofService(map);

    const proof = await prover.GenerateReleaseProof({
      msgHash: ethers.constants.HashZero,
      sender: ethers.constants.AddressZero,
      destBridgeAddress: ethers.constants.AddressZero,
      srcChain: srcChain,
      destChain: destChain,
      destHeaderSyncAddress: ethers.constants.AddressZero,
      srcHeaderSyncAddress: ethers.constants.AddressZero,
    });
    expect(proof).toBe(expectedProofWithBaseFee);
  });
});
