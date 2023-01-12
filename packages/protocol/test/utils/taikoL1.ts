import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { AddressManager, TaikoL1 } from "../../typechain";

const defaultFeeBase = BigNumber.from(10).pow(18);

async function deployTaikoL1(
    genesisHash: string,
    enableTokenomics: boolean,
    feeBase?: BigNumber
): Promise<{ taikoL1: TaikoL1; addressManager: AddressManager }> {
    const addressManager = await (
        await ethers.getContractFactory("AddressManager")
    ).deploy();
    await addressManager.init();

    const libReceiptDecoder = await (
        await ethers.getContractFactory("LibReceiptDecoder")
    ).deploy();

    const libTxDecoder = await (
        await ethers.getContractFactory("LibTxDecoder")
    ).deploy();

    const libProposing = await (
        await ethers.getContractFactory("LibProposing")
    ).deploy();

    const libProving = await (
        await ethers.getContractFactory("LibProving", {
            libraries: {
                LibReceiptDecoder: libReceiptDecoder.address,
                LibTxDecoder: libTxDecoder.address,
            },
        })
    ).deploy();

    const libVerifying = await (
        await ethers.getContractFactory("LibVerifying")
    ).deploy();

    const taikoL1 = await (
        await ethers.getContractFactory(
            enableTokenomics ? "TestTaikoL1EnableTokenomics" : "TestTaikoL1",
            {
                libraries: {
                    LibVerifying: libVerifying.address,
                    LibProposing: libProposing.address,
                    LibProving: libProving.address,
                },
            }
        )
    ).deploy();

    await taikoL1.init(
        addressManager.address,
        genesisHash,
        feeBase ?? defaultFeeBase
    );

    return { taikoL1: taikoL1 as TaikoL1, addressManager: addressManager };
}

export { deployTaikoL1, defaultFeeBase };
