export interface Data {
  Raw: Raw;
  Signal?: number[] | null;
  Message: Message;
}
export interface Raw {
  data: string;
  topics?: string[] | null;
  address: string;
  removed: boolean;
  logIndex: string;
  blockHash: string;
  blockNumber: string;
  transactionHash: string;
  transactionIndex: string;
}
export interface Message {
  Id: number;
  To: string;
  Data: string;
  Memo: string;
  Owner: string;
  Sender: string;
  GasLimit: number;
  CallValue: number;
  SrcChainId: number;
  DestChainId: number;
  DepositValue: number;
  ProcessingFee: number;
  RefundAddress: string;
}

export type BridgeTransaction = {
  id: number;
  name: string;
  data: string;
  status: number;
  chainID: number;
  rawData: Data;
};

export interface Transactioner {
  GetAllByAddress(
    address: string,
    chainID?: number
  ): Promise<BridgeTransaction[]>;
}
