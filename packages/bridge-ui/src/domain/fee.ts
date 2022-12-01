enum ProcessingFeeMethod {
  RECOMMENDED = "recommended",
  CUSTOM = "custom",
  NONE = "none",
};

interface ProcessingFeeDetails {
  DisplayText: string;
  TimeToConfirm: number;
};

const PROCESSING_FEE_META: Map<ProcessingFeeMethod, ProcessingFeeDetails> =  new Map([[ProcessingFeeMethod.RECOMMENDED, {
  displayText: "Recommended",
  timeToConfirm: 15 * 60 * 1000,
}], [ProcessingFeeMethod.CUSTOM, {
  displayText: "Custom Amount",
  timeToConfirm: 15 * 60 * 1000,
}], [ProcessingFeeMethod.NONE, {
  displayText: "No Fees",
  timeToConfirm: 15 * 60 * 1000,
}]]);

export { ProcessingFeeDetails, ProcessingFeeMethod, PROCESSING_FEE_META };