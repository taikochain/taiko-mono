// import { expect } from "chai"
import { expect } from "chai"
import { ethers } from "hardhat"
import { Message } from "../../utils/message"

describe("LibBridgeInvoke", function () {
    async function deployLibBridgeDataFixture() {
        const libData = await (
            await ethers.getContractFactory("TestLibBridgeData")
        ).deploy()
        return { libData }
    }

    async function deployLibBridgeInvokeFixture() {
        const [owner, nonOwner] = await ethers.getSigners()

        const libInvoke = await (
            await ethers.getContractFactory("TestLibBridgeInvoke")
        ).deploy()

        return { owner, nonOwner, libInvoke }
    }

    describe("invokeMessageCall()", async function () {
        it("should throw when gasLimit <= 0", async function () {
            const { owner, nonOwner, libInvoke } =
                await deployLibBridgeInvokeFixture()

            const { libData } = await deployLibBridgeDataFixture()

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
                gasLimit: 0,
                data: ethers.constants.HashZero,
                memo: "",
            }

            const signal = await libData.hashMessage(message)

            await expect(
                libInvoke.invokeMessageCall(message, signal, message.gasLimit)
            ).to.be.revertedWith("B:gasLimit")
        })

        it("should emit event with success false if message does not actually invoke", async function () {
            const { owner, nonOwner, libInvoke } =
                await deployLibBridgeInvokeFixture()

            const { libData } = await deployLibBridgeDataFixture()

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
                gasLimit: 100,
                data: ethers.constants.HashZero,
                memo: "",
            }

            const signal = await libData.hashMessage(message)

            await expect(
                libInvoke.invokeMessageCall(message, signal, message.gasLimit)
            )
                .to.emit(libInvoke, "MessageInvoked")
                .withArgs(signal, false)
        })

        it.only("should emit event with success true if message invokes successfully", async function () {
            const { owner, nonOwner, libInvoke } =
                await deployLibBridgeInvokeFixture()

            const { libData } = await deployLibBridgeDataFixture()

            const testERC20Token = await (
                await ethers.getContractFactory("TestERC20Receiver")
            ).deploy()

            const testTypes = ["string", "address"]

            const data = ethers.utils.defaultAbiCoder.encode(testTypes, [
                "receiveMessage(address)",
                nonOwner.address,
            ])

            const message: Message = {
                id: 1,
                sender: owner.address,
                srcChainId: 1,
                destChainId: 5,
                owner: owner.address,
                to: testERC20Token.address,
                refundAddress: owner.address,
                depositValue: 1,
                callValue: 1,
                processingFee: 1,
                gasLimit: 100,
                data: data,
                memo: "",
            }

            const signal = await libData.hashMessage(message)

            await expect(
                libInvoke.invokeMessageCall(message, signal, message.gasLimit)
            )
                .to.emit(libInvoke, "MessageInvoked")
                .withArgs(signal, true)
        })
    })
})
