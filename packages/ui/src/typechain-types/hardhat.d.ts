/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { ethers } from "ethers";
import {
  FactoryOptions,
  HardhatEthersHelpers as HardhatEthersHelpersBase,
} from "@nomiclabs/hardhat-ethers/types";

import * as Contracts from ".";

declare module "hardhat/types/runtime" {
  interface HardhatEthersHelpers extends HardhatEthersHelpersBase {
    getContractFactory(
      name: "Ownable",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.Ownable__factory>;
    getContractFactory(
      name: "ERC20",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.ERC20__factory>;
    getContractFactory(
      name: "IERC20Metadata",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC20Metadata__factory>;
    getContractFactory(
      name: "IERC20",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.IERC20__factory>;
    getContractFactory(
      name: "L1ERC20Bridge",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.L1ERC20Bridge__factory>;
    getContractFactory(
      name: "L1ERC20Token",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.L1ERC20Token__factory>;
    getContractFactory(
      name: "L2ERC20Bridge",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.L2ERC20Bridge__factory>;
    getContractFactory(
      name: "L2ERC20Token",
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<Contracts.L2ERC20Token__factory>;

    getContractAt(
      name: "Ownable",
      address: string,
      signer?: ethers.Signer
    ): Promise<Contracts.Ownable>;
    getContractAt(
      name: "ERC20",
      address: string,
      signer?: ethers.Signer
    ): Promise<Contracts.ERC20>;
    getContractAt(
      name: "IERC20Metadata",
      address: string,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC20Metadata>;
    getContractAt(
      name: "IERC20",
      address: string,
      signer?: ethers.Signer
    ): Promise<Contracts.IERC20>;
    getContractAt(
      name: "L1ERC20Bridge",
      address: string,
      signer?: ethers.Signer
    ): Promise<Contracts.L1ERC20Bridge>;
    getContractAt(
      name: "L1ERC20Token",
      address: string,
      signer?: ethers.Signer
    ): Promise<Contracts.L1ERC20Token>;
    getContractAt(
      name: "L2ERC20Bridge",
      address: string,
      signer?: ethers.Signer
    ): Promise<Contracts.L2ERC20Bridge>;
    getContractAt(
      name: "L2ERC20Token",
      address: string,
      signer?: ethers.Signer
    ): Promise<Contracts.L2ERC20Token>;

    // default types
    getContractFactory(
      name: string,
      signerOrOptions?: ethers.Signer | FactoryOptions
    ): Promise<ethers.ContractFactory>;
    getContractFactory(
      abi: any[],
      bytecode: ethers.utils.BytesLike,
      signer?: ethers.Signer
    ): Promise<ethers.ContractFactory>;
    getContractAt(
      nameOrAbi: string | any[],
      address: string,
      signer?: ethers.Signer
    ): Promise<ethers.Contract>;
  }
}
