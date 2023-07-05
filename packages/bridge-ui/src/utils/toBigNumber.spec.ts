import { BigNumber } from "ethers";

import { toBigNumber } from "./toBigNumber";

describe('toBigNumber', () => {
  it('should handle different notation for big ints', () => {
    expect(toBigNumber('1000000000000000000000').toString()).toEqual('1000000000000000000000');
    expect(toBigNumber(2e+21).toString()).toEqual('2000000000000000000000');
    expect(toBigNumber(3e21).toString()).toEqual('3000000000000000000000');
    expect(toBigNumber(1000).toString()).toEqual('1000');
  });
});
