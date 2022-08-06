import { expect } from "chai"
import { ethers } from "hardhat"
import { UnsignedTransaction } from "ethers"

describe("LibTxList", function () {
    let rlpWriter: any
    let libTxList: any
    let signer0: any

    before(async function () {
        rlpWriter = await (
            await ethers.getContractFactory("TestLib_RLPWriter")
        ).deploy()
        libTxList = await (
            await ethers.getContractFactory("LibTxList")
        ).deploy()

        signer0 = (await ethers.getSigners())[0]
    })

    async function rlpEncodeTxList(txList: string[]) {
        const rlpEncodedBytes = []
        for (const tx of txList) {
            const txRlp = await rlpWriter.writeBytes(tx)
            rlpEncodedBytes.push(txRlp)
        }
        const txListBytes = await rlpWriter.writeList(rlpEncodedBytes)
        return txListBytes
    }

    describe("decodeTxList", function () {
        it("should revert if tx list is empty", async function () {
            const txList: string[] = []
            const txListBytes = await rlpEncodeTxList(txList)
            await expect(
                libTxList.callStatic.decodeTxList(txListBytes)
            ).to.be.revertedWith("empty txList")
        })

        it("should revert with random bytes", async function () {
            const randomBytes = ethers.utils.hexlify(
                ethers.utils.randomBytes(73)
            )
            await expect(
                libTxList.callStatic.decodeTxList(randomBytes)
            ).to.be.revertedWith("Invalid RLP")
        })

        it("should be able to decode txList with legacy transaction", async function () {
            const txLegacy: UnsignedTransaction = {
                nonce: 1,
                gasPrice: 11e9,
                gasLimit: 123456,
                to: ethers.Wallet.createRandom().address,
                value: ethers.utils.parseEther("1.23"),
                data: ethers.utils.randomBytes(10),
            }

            const signature = await signer0.signMessage("abc123")
            // console.log('signature: ', signature)

            const txLegacyBytes = ethers.utils.serializeTransaction(
                txLegacy,
                signature
            )
            console.log("txLegacyBytes: ", txLegacyBytes)
            const txListBytes = await rlpEncodeTxList([txLegacyBytes])
            console.log("txListBytes: ", txListBytes)

            const decodedTxList = await libTxList.callStatic.decodeTxList(
                txListBytes
            )
            // console.log('decodedT: ', decodedTxList)
            expect(decodedTxList.items.length).to.equal(1)
            const decodedTx1 = decodedTxList.items[0]
            expect(decodedTx1.gasLimit.toNumber()).to.equal(txLegacy.gasLimit)
        })

        it("should be able to decode txList with 2930 transaction", async function () {
            const tx2930: UnsignedTransaction = {
                type: 1,
                chainId: 12345,
                nonce: 123,
                gasPrice: 11e9,
                gasLimit: 123,
                to: ethers.Wallet.createRandom().address,
                value: ethers.utils.parseEther("10.23"),
                accessList: [],
                data: ethers.utils.randomBytes(20),
            }

            const signature = await signer0.signMessage(tx2930.data?.toString())
            console.log("signature: ", signature)

            const txBytes = ethers.utils.serializeTransaction(tx2930, signature)
            console.log("txBytes: ", txBytes)
            const txListBytes = await rlpEncodeTxList([txBytes])
            console.log("txListBytes: ", txListBytes)

            const decodedTxList = await libTxList.callStatic.decodeTxList(
                txListBytes
            )
            expect(decodedTxList.items.length).to.equal(1)
            const decodedTx1 = decodedTxList.items[0]
            expect(decodedTx1.gasLimit.toNumber()).to.equal(tx2930.gasLimit)
        })

        it("should be able to decode txList with 1559 transaction", async function () {
            const tx1559: UnsignedTransaction = {
                type: 2,
                chainId: 12345,
                nonce: 123,
                maxPriorityFeePerGas: 2e9,
                maxFeePerGas: 22e9,
                gasLimit: 1234567,
                to: ethers.Wallet.createRandom().address,
                value: ethers.utils.parseEther("10.123"),
                accessList: [],
                data: ethers.utils.randomBytes(20),
            }

            const signature = await signer0.signMessage(tx1559.data?.toString())
            console.log("signature: ", signature)

            const txBytes = ethers.utils.serializeTransaction(tx1559, signature)
            console.log("txBytes: ", txBytes)
            const txListBytes = await rlpEncodeTxList([txBytes])
            console.log("txListBytes: ", txListBytes)

            const decodedTxList = await libTxList.callStatic.decodeTxList(
                txListBytes
            )
            expect(decodedTxList.items.length).to.equal(1)
            const decodedTx1 = decodedTxList.items[0]
            expect(decodedTx1.gasLimit.toNumber()).to.equal(tx1559.gasLimit)
        })
    })

    it("should be able to decode txList with multiple types", async function () {
        const signature = await signer0.signMessage("123456abcdef")
        const txLegacy: UnsignedTransaction = {
            nonce: 1,
            gasPrice: 11e9,
            gasLimit: 123456,
            to: ethers.Wallet.createRandom().address,
            value: ethers.utils.parseEther("1.23"),
            data: ethers.utils.randomBytes(10),
        }

        const tx2930: UnsignedTransaction = {
            type: 1,
            chainId: 12345,
            nonce: 123,
            gasPrice: 11e9,
            gasLimit: 123,
            to: ethers.Wallet.createRandom().address,
            value: ethers.utils.parseEther("10.23"),
            accessList: [],
            data: ethers.utils.randomBytes(20),
        }

        const tx1559: UnsignedTransaction = {
            type: 2,
            chainId: 12345,
            nonce: 123,
            maxPriorityFeePerGas: 2e9,
            maxFeePerGas: 22e9,
            gasLimit: 1234567,
            to: ethers.Wallet.createRandom().address,
            value: ethers.utils.parseEther("10.123"),
            accessList: [],
            data: ethers.utils.randomBytes(20),
        }

        const txObjArr = [txLegacy, tx2930, tx1559]
        const txRawBytesArr = []
        for (const txObj of txObjArr) {
            const txBytes = ethers.utils.serializeTransaction(txObj, signature)
            txRawBytesArr.push(txBytes)
        }
        const txListBytes = await rlpEncodeTxList(txRawBytesArr)

        const decodedTxList = await libTxList.callStatic.decodeTxList(
            txListBytes
        )
        // console.log('decodedT: ', decodedTxList)
        expect(decodedTxList.items.length).to.equal(txObjArr.length)
        for (let i = 0; i < txObjArr.length; i++) {
            const txObj = txObjArr[i]
            const decodedTx = decodedTxList.items[i]
            expect(decodedTx.gasLimit.toNumber()).to.equal(txObj.gasLimit)
        }
    })
})
