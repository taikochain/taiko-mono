import * as helpers from "@nomicfoundation/hardhat-network-helpers"
import { expect } from "chai"
import hre, { ethers } from "hardhat"
import { decode, getSlot, MessageStatus } from "../../../tasks/utils"
import { Message } from "../../utils/message"

describe("LibBridgeRetry", function () {
    async function deployLibBridgeRetryFixture() {
        const [owner, refundAddress, nonOwner, etherVaultOwner] =
            await ethers.getSigners()

        const addressManager = await (
            await ethers.getContractFactory("AddressManager")
        ).deploy()
        await addressManager.init()

        const badAddressManager = await (
            await ethers.getContractFactory("AddressManager")
        ).deploy()
        await badAddressManager.init()

        const etherVault = await (await ethers.getContractFactory("EtherVault"))
            .connect(etherVaultOwner)
            .deploy()

        await etherVault.deployed()

        await etherVault.init(addressManager.address)

        await etherVault.connect(etherVaultOwner).authorize(owner.address, true)
        const blockChainId = hre.network.config.chainId ?? 0
        await addressManager.setAddress(
            `${blockChainId}.ether_vault`,
            etherVault.address
        )

        await badAddressManager.setAddress(
            `${blockChainId}.ether_vault`,
            ethers.constants.AddressZero
        )

        await owner.sendTransaction({
            to: etherVault.address,
            value: ethers.utils.parseEther("10.0"),
        })

        const libRetryLink = await (
            await ethers.getContractFactory("LibBridgeRetry")
        ).deploy()
        await libRetryLink.deployed()

        const libRetryFactory = await (
            await ethers.getContractFactory("TestLibBridgeRetry", {
                libraries: {
                    LibBridgeRetry: libRetryLink.address,
                },
            })
        ).connect(owner)

        const libRetry = await libRetryFactory.deploy()
        await libRetry.init(addressManager.address)
        await libRetry.deployed()

        const badLibRetry = await libRetryFactory.deploy()
        await badLibRetry.init(badAddressManager.address)
        await badLibRetry.deployed()

        await etherVault
            .connect(etherVaultOwner)
            .authorize(libRetry.address, true)

        const testLibData = await (
            await ethers.getContractFactory("TestLibBridgeData")
        ).deploy()

        return {
            owner,
            refundAddress,
            nonOwner,
            libRetry,
            testLibData,
            MessageStatus,
            badLibRetry,
        }
    }

    describe("retryMessage()", async function () {
        it("should throw if message.gaslimit == 0 && msg.sender != message.owner", async function () {
            const { owner, nonOwner, libRetry } =
                await deployLibBridgeRetryFixture()

            const message: Message = {
                id: 1,
                sender: owner.address,
                srcChainId: 1,
                destChainId: 5,
                owner: nonOwner.address,
                to: nonOwner.address,
                refundAddress: owner.address,
                depositValue: 1,
                callValue: 1,
                processingFee: 1,
                gasLimit: 0,
                data: ethers.constants.HashZero,
                memo: "",
            }

            await expect(
                libRetry.retryMessage(message, false)
            ).to.be.revertedWith("B:denied")
        })

        it("should throw if lastAttempt == true && msg.sender != message.owner", async function () {
            const { owner, nonOwner, libRetry } =
                await deployLibBridgeRetryFixture()

            const message: Message = {
                id: 1,
                sender: owner.address,
                srcChainId: 1,
                destChainId: 5,
                owner: nonOwner.address,
                to: nonOwner.address,
                refundAddress: owner.address,
                depositValue: 1,
                callValue: 1,
                processingFee: 1,
                gasLimit: 1000000,
                data: ethers.constants.HashZero,
                memo: "",
            }

            await expect(
                libRetry.retryMessage(message, true)
            ).to.be.revertedWith("B:denied")
        })

        it("should throw if message status is not RETRIABLE", async function () {
            const { owner, nonOwner, libRetry } =
                await deployLibBridgeRetryFixture()

            const message: Message = {
                id: 1,
                sender: owner.address,
                srcChainId: 1,
                destChainId: 5,
                owner: owner.address,
                to: nonOwner.address,
                refundAddress: owner.address,
                depositValue: 1,
                callValue: 1,
                processingFee: 1,
                gasLimit: 300000,
                data: ethers.constants.HashZero,
                memo: "",
            }

            await expect(
                libRetry.retryMessage(message, false)
            ).to.be.revertedWith("B:notFound")
        })

        it("if etherVault resolves to address(0), retry should fail and messageStatus should not change if not lastAttempt since no ether received", async function () {
            const {
                owner,
                refundAddress,
                testLibData,
                MessageStatus,
                badLibRetry,
            } = await deployLibBridgeRetryFixture()

            const testReceiver = await (
                await ethers.getContractFactory("TestReceiver")
            ).deploy()

            await testReceiver.deployed()

            const destChainId = 5
            const message: Message = {
                id: 1,
                sender: owner.address,
                srcChainId: 1,
                destChainId: destChainId,
                owner: owner.address,
                to: testReceiver.address,
                refundAddress: refundAddress.address,
                depositValue: 1,
                callValue: 1,
                processingFee: 1,
                gasLimit: 1,
                data: ethers.constants.HashZero,
                memo: "",
            }

            const signal = await testLibData.hashMessage(message)

            await helpers.setStorageAt(
                badLibRetry.address,
                await getSlot(hre, signal, 202),
                MessageStatus.RETRIABLE
            )

            const originalToBalance = await testReceiver.getBalance()
            await badLibRetry.retryMessage(message, false)
            const newToBalance = await testReceiver.getBalance()
            expect(
                await decode(
                    hre,
                    "uint256",
                    await ethers.provider.getStorageAt(
                        badLibRetry.address,
                        getSlot(hre, signal, 202)
                    )
                )
            ).to.equal(MessageStatus.RETRIABLE.toString())

            expect(newToBalance).to.be.equal(originalToBalance)
        })

        it("should fail, but since lastAttempt == true messageStatus should be set to DONE", async function () {
            const {
                owner,
                libRetry,
                refundAddress,
                testLibData,
                MessageStatus,
            } = await deployLibBridgeRetryFixture()

            const testBadReceiver = await (
                await ethers.getContractFactory("TestBadReceiver")
            ).deploy()

            await testBadReceiver.deployed()

            const destChainId = 5
            const message: Message = {
                id: 1,
                sender: owner.address,
                srcChainId: 1,
                destChainId: destChainId,
                owner: owner.address,
                to: testBadReceiver.address,
                refundAddress: refundAddress.address,
                depositValue: 1,
                callValue: 1,
                processingFee: 1,
                gasLimit: 300000,
                data: ethers.constants.HashZero,
                memo: "",
            }

            const signal = await testLibData.hashMessage(message)

            await helpers.setStorageAt(
                libRetry.address,
                await getSlot(hre, signal, 202),
                MessageStatus.RETRIABLE
            )

            const originalBalance = await refundAddress.getBalance()
            await libRetry.retryMessage(message, true)
            const balancePlusRefund = await refundAddress.getBalance()

            expect(
                await decode(
                    hre,
                    "uint256",
                    await ethers.provider.getStorageAt(
                        libRetry.address,
                        getSlot(hre, signal, 202)
                    )
                )
            ).to.equal(MessageStatus.FAILED.toString())

            expect(balancePlusRefund).to.be.equal(
                originalBalance.add(message.callValue)
            )
        })

        it("should succeed, set message status to done, invoke message succesfsully", async function () {
            const {
                owner,
                libRetry,
                refundAddress,
                testLibData,
                MessageStatus,
            } = await deployLibBridgeRetryFixture()

            const testReceiver = await (
                await ethers.getContractFactory("TestReceiver")
            ).deploy()

            await testReceiver.deployed()

            const destChainId = 5
            const message: Message = {
                id: 1,
                sender: owner.address,
                srcChainId: 1,
                destChainId: destChainId,
                owner: owner.address,
                to: testReceiver.address,
                refundAddress: refundAddress.address,
                depositValue: 1,
                callValue: 1,
                processingFee: 1,
                gasLimit: 1,
                data: ethers.constants.HashZero,
                memo: "",
            }

            const signal = await testLibData.hashMessage(message)

            await helpers.setStorageAt(
                libRetry.address,
                await getSlot(hre, signal, 202),
                MessageStatus.RETRIABLE
            )

            const originalToBalance = await testReceiver.getBalance()
            await libRetry.retryMessage(message, true)
            const newToBalance = await testReceiver.getBalance()

            expect(
                await decode(
                    hre,
                    "uint256",
                    await ethers.provider.getStorageAt(
                        libRetry.address,
                        getSlot(hre, signal, 202)
                    )
                )
            ).to.equal(MessageStatus.DONE.toString())

            expect(newToBalance).to.be.equal(
                originalToBalance.add(message.callValue)
            )
        })
    })
})
