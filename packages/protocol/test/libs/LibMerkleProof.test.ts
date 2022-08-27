import { expect } from "chai"
import { Contract } from "ethers"
// eslint-disable-next-line node/no-extraneous-import
import * as rlp from "rlp"
import * as utils from "../../tasks/utils"
const hre = require("hardhat")

const action = process.env.TEST_LIB_MERKLE_PROOF ? describe : describe.skip

action("LibMerkleProof", function () {
    let libMerkleProof: Contract
    let taikoL2: Contract
    let libStorageProof: Contract

    before(async () => {
        hre.args = { confirmations: 1 }
        if (hre.network.name === "hardhat") {
            throw new Error(`hardhat: eth_getProof - Method not supported`)
        }

        const addressManager = await utils.deployContract(hre, "AddressManager")
        await utils.waitTx(hre, await addressManager.init())

        libStorageProof = await utils.deployContract(
            hre,
            "TestLibStorageProof",
            {
                LibStorageProof: (
                    await utils.deployContract(hre, "LibStorageProof")
                ).address,
            }
        )

        const libTxListDecoder = await utils.deployContract(
            hre,
            "LibTxListDecoder"
        )

        libMerkleProof = await utils.deployContract(hre, "LibMerkleProof")
        taikoL2 = await utils.deployContract(hre, "TaikoL2", {
            LibTxListDecoder: libTxListDecoder.address,
            LibStorageProof: libStorageProof.address,
        })
    })

    it("should verify inclusion proofs", async function () {
        const anchorHeight = Math.floor(Math.random() * 1024)
        const anchorHash = hre.ethers.utils.randomBytes(32)

        const anchorReceipt = await utils.waitTx(
            hre,
            await taikoL2.anchor(anchorHeight, anchorHash)
        )

        expect(anchorReceipt.status).to.be.equal(1)

        const ancestorHashes = await taikoL2.getAncestorHashes(
            anchorReceipt.blockNumber
        )

        const anchorKV = await libStorageProof.computeAnchorProofKV(
            anchorReceipt.blockNumber,
            await libStorageProof.aggregateAncestorHashs(ancestorHashes),
            anchorHeight,
            anchorHash
        )

        expect(anchorKV[0].length).not.to.be.equal(
            hre.ethers.constants.HashZero
        )
        expect(anchorKV[1].length).not.to.be.equal(
            hre.ethers.constants.HashZero
        )

        const proof = await hre.ethers.provider.send("eth_getProof", [
            taikoL2.address,
            [anchorKV[0]],
            hre.ethers.utils.hexValue(
                hre.ethers.utils.hexlify(anchorReceipt.blockNumber)
            ),
        ])

        expect(proof.storageProof[0].key).to.be.equal(anchorKV[0])
        expect(proof.storageProof[0].value).to.be.equal(anchorKV[1])

        const coder = new hre.ethers.utils.AbiCoder()
        const mkproof = coder.encode(
            ["bytes", "bytes"],
            [
                `0x` + rlp.encode(proof.accountProof).toString("hex"),
                `0x` + rlp.encode(proof.storageProof[0].proof).toString("hex"),
            ]
        )

        const block = await hre.ethers.provider.send("eth_getBlockByNumber", [
            hre.ethers.utils.hexValue(
                hre.ethers.utils.hexlify(anchorReceipt.blockNumber)
            ),
            false,
        ])

        await libMerkleProof.callStatic.verifyStorage(
            block.stateRoot,
            taikoL2.address,
            anchorKV[0],
            anchorKV[1],
            mkproof
        )

        await expect(
            libMerkleProof.callStatic.verifyStorage(
                block.stateRoot,
                taikoL2.address,
                anchorKV[0],
                hre.ethers.utils.randomBytes(32),
                mkproof
            )
        ).to.be.reverted
    })
})
