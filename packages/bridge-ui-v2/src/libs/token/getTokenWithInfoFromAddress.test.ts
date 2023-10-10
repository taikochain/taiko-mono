import { fetchToken, type FetchTokenResult, readContract } from '@wagmi/core';
import { type Address, zeroAddress } from 'viem';

import { UnknownTokenTypeError } from '$libs/error';

import { detectContractType } from './detectContractType';
import { getTokenWithInfoFromAddress } from './getTokenWithInfoFromAddress';
import { TokenType } from './types';

vi.mock('@wagmi/core');

vi.mock('./errors', () => {
  return {
    UnknownTypeError: vi.fn().mockImplementation(() => {
      return { message: 'Mocked UnknownTypeError' };
    }),
  };
});

vi.mock('./detectContractType', () => {
  const actual = vi.importActual('./detectContractType');
  return {
    ...actual,
    detectContractType: vi.fn(),
  };
});

describe('getTokenWithInfoFromAddress', () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('ERC20', () => {
    it('should return correct token details for ERC20 tokens', async () => {
      // Given
      const address: Address = zeroAddress;
      vi.mocked(detectContractType).mockResolvedValue(TokenType.ERC20);
      vi.mocked(fetchToken).mockResolvedValue({
        name: 'MockToken',
        symbol: 'MTK',
        decimals: 18,
      } as FetchTokenResult);

      // When
      const result = await getTokenWithInfoFromAddress({ contractAddress: address, srcChainId: 1 });

      // Then
      expect(result).toEqual({
        addresses: {
          1: address,
        },
        name: 'MockToken',
        symbol: 'MTK',
        decimals: 18,
        type: TokenType.ERC20,
      });

      expect(fetchToken).toHaveBeenCalledOnce();
      expect(fetchToken).toHaveBeenCalledWith({
        address,
        chainId: 1,
      });
    });
  });

  describe('ERC721', () => {
    it('should return correct token details for ERC721 tokens', async () => {
      // Given
      const address: Address = zeroAddress;
      vi.mocked(detectContractType).mockResolvedValue(TokenType.ERC721);
      vi.mocked(readContract)
        .mockResolvedValueOnce('Mock721')
        .mockResolvedValueOnce('MNFT')
        .mockResolvedValueOnce('some/uri/123');

      // When
      const result = await getTokenWithInfoFromAddress({ contractAddress: address, srcChainId: 1, tokenId: 123 });

      // Then
      expect(result).toEqual({
        addresses: {
          1: address,
        },
        uri: 'some/uri/123',
        tokenId: 123,
        name: 'Mock721',
        symbol: 'MNFT',
        type: TokenType.ERC721,
      });
      expect(readContract).toHaveBeenCalledTimes(3);
    });
  });
  describe('ERC1155', () => {
    it('should return correct token details for ERC1155 tokens', async () => {
      // Given
      const address: Address = zeroAddress;
      vi.mocked(detectContractType).mockResolvedValue(TokenType.ERC1155);
      vi.mocked(readContract)
        .mockResolvedValueOnce('Mock1155')
        .mockResolvedValueOnce('some/uri/123')
        .mockResolvedValueOnce(1337n);
      // When
      const result = await getTokenWithInfoFromAddress({
        contractAddress: address,
        srcChainId: 1,
        tokenId: 123,
        owner: zeroAddress,
      });

      // Then
      expect(result).toEqual({
        addresses: {
          1: address,
        },
        uri: 'some/uri/123',
        tokenId: 123,
        name: 'Mock1155',
        balance: 1337n,
        type: TokenType.ERC1155,
      });
    });

    it('should return correct token details for ERC1155 tokens with no owner passed', async () => {
      // Given
      const address: Address = zeroAddress;
      vi.mocked(detectContractType).mockResolvedValue(TokenType.ERC1155);
      vi.mocked(readContract)
        .mockResolvedValueOnce('Mock1155')
        .mockResolvedValueOnce('some/uri/123')
        .mockResolvedValueOnce(1337n);
      // When
      const result = await getTokenWithInfoFromAddress({ contractAddress: address, srcChainId: 1, tokenId: 123 });

      // Then
      expect(result).toEqual({
        addresses: {
          1: address,
        },
        uri: 'some/uri/123',
        tokenId: 123,
        name: 'Mock1155',
        balance: 0,
        type: TokenType.ERC1155,
      });
    });
  });

  it('should throw for unknown token types', async () => {
    // Given
    const address: Address = zeroAddress;
    vi.mocked(detectContractType).mockRejectedValue(new UnknownTokenTypeError());

    // When
    try {
      await getTokenWithInfoFromAddress({ contractAddress: address, srcChainId: 1 });
      expect.fail('should have thrown');
    } catch (error) {
      expect(readContract).not.toHaveBeenCalled();
      expect(fetchToken).not.toHaveBeenCalled();
    }
  });
});
