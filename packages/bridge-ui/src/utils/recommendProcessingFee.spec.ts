const mockChainIdToTokenVaultAddress = jest.fn();
jest.mock('../store/bridge', () => ({
  chainIdToTokenVaultAddress: mockChainIdToTokenVaultAddress,
}));

const mockGet = jest.fn();

import { BigNumber, ethers, Signer } from 'ethers';
import { chainIdToTokenVaultAddress } from '../store/bridge';
import { get } from 'svelte/store';
import { ProcessingFeeMethod } from '../domain/fee';
import { signer } from '../store/signer';
import {
  erc20DeployedGasLimit,
  erc20NotDeployedGasLimit,
  ethGasLimit,
  recommendProcessingFee,
} from './recommendProcessingFee';
import { mainnetChain, taikoChain } from '../chain/chains';
import { ETHToken, testERC20Tokens } from '../token/tokens';

jest.mock('svelte/store', () => ({
  ...jest.requireActual('svelte/store'),
  get: function () {
    return mockGet();
  },
}));

const mockContract = {
  canonicalToBridged: jest.fn(),
};

const mockProver = {
  GenerateProof: jest.fn(),
};

jest.mock('ethers', () => ({
  /* eslint-disable-next-line */
  ...(jest.requireActual('ethers') as object),
  Contract: function () {
    return mockContract;
  },
}));

const gasPrice = 2;
const mockProvider = {
  getGasPrice: () => {
    return 2;
  },
};

const mockSigner = {} as Signer;

describe('recommendProcessingFee()', () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });

  it('returns zero if values not set', async () => {
    expect(
      await recommendProcessingFee(
        null,
        mainnetChain,
        ProcessingFeeMethod.RECOMMENDED,
        ETHToken,
        get(signer),
      ),
    ).toStrictEqual('0');

    expect(
      await recommendProcessingFee(
        mainnetChain,
        null,
        ProcessingFeeMethod.RECOMMENDED,
        ETHToken,
        get(signer),
      ),
    ).toStrictEqual('0');

    expect(
      await recommendProcessingFee(
        mainnetChain,
        taikoChain,
        null,
        ETHToken,
        get(signer),
      ),
    ).toStrictEqual('0');

    expect(
      await recommendProcessingFee(
        taikoChain,
        mainnetChain,
        ProcessingFeeMethod.RECOMMENDED,
        null,
        get(signer),
      ),
    ).toStrictEqual('0');

    expect(
      await recommendProcessingFee(
        taikoChain,
        mainnetChain,
        ProcessingFeeMethod.RECOMMENDED,
        ETHToken,
        null,
      ),
    ).toStrictEqual('0');
  });

  it('uses ethGasLimit if the token is ETH', async () => {
    mockGet.mockImplementationOnce(() =>
      new Map<number, ethers.providers.JsonRpcProvider>().set(
        taikoChain.id,
        mockProvider as unknown as ethers.providers.JsonRpcProvider,
      ),
    );

    const fee = await recommendProcessingFee(
      taikoChain,
      mainnetChain,
      ProcessingFeeMethod.RECOMMENDED,
      ETHToken,
      mockSigner as unknown as Signer,
    );

    const expected = ethers.utils.formatEther(
      BigNumber.from(gasPrice).mul(ethGasLimit),
    );

    expect(fee).toStrictEqual(expected);
  });

  it('uses erc20NotDeployedGasLimit if the token is not ETH and token is not deployed on dest layer', async () => {
    mockGet.mockImplementation((store: any) => {
      if (typeof store === typeof chainIdToTokenVaultAddress) {
        return new Map<number, string>().set(mainnetChain.id, '0x12345');
      } else {
        return new Map<number, ethers.providers.JsonRpcProvider>().set(
          taikoChain.id,
          mockProvider as unknown as ethers.providers.JsonRpcProvider,
        );
      }
    });
    mockContract.canonicalToBridged.mockImplementationOnce(
      () => ethers.constants.AddressZero,
    );

    const fee = await recommendProcessingFee(
      taikoChain,
      mainnetChain,
      ProcessingFeeMethod.RECOMMENDED,
      testERC20Tokens[0],
      mockSigner,
    );

    const expected = ethers.utils.formatEther(
      BigNumber.from(gasPrice).mul(erc20NotDeployedGasLimit),
    );

    expect(fee).toStrictEqual(expected);
  });

  it('uses erc20NotDeployedGasLimit if the token is not ETH and token is not deployed on dest layer', async () => {
    mockGet.mockImplementation((store: any) => {
      if (typeof store === typeof chainIdToTokenVaultAddress) {
        return new Map<number, string>().set(mainnetChain.id, '0x12345');
      } else {
        return new Map<number, ethers.providers.JsonRpcProvider>().set(
          taikoChain.id,
          mockProvider as unknown as ethers.providers.JsonRpcProvider,
        );
      }
    });

    mockContract.canonicalToBridged.mockImplementationOnce(() => '0x123');

    const fee = await recommendProcessingFee(
      taikoChain,
      mainnetChain,
      ProcessingFeeMethod.RECOMMENDED,
      testERC20Tokens[0],
      mockSigner,
    );

    const expected = ethers.utils.formatEther(
      BigNumber.from(gasPrice).mul(erc20DeployedGasLimit),
    );

    expect(fee).toStrictEqual(expected);
  });
});
