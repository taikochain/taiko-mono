import { expect } from "chai"
const hre = require("hardhat")
const ethers = hre.ethers
const Web3 = require("web3")
const web3 = new Web3(Web3.givenProvider || "ws://localhost:8545")

describe("Test Bridge Libs", function () {
    let signers: any
    let addressManager: any
    let bridge: any
    let testMessage: any
    let libData: any
    let testTypes: any
    let testVar: any

    before(async function () {
        signers = await ethers.getSigners()

        // deploy addressManager
        addressManager = await (
            await ethers.getContractFactory("AddressManager")
        ).deploy()
        await addressManager.init()

        // deploy Libraries needed to link to Bridge
        const libTrie = await (
            await ethers.getContractFactory("LibTrieProof")
        ).deploy()

        const libProcess = await (
            await ethers.getContractFactory("LibBridgeProcess", {
                libraries: {
                    LibTrieProof: libTrie.address,
                },
            })
        ).deploy()

        const libRetry = await (
            await ethers.getContractFactory("LibBridgeRetry")
        ).deploy()

        // deploying Bridge
        bridge = await (
            await ethers.getContractFactory("Bridge", {
                libraries: {
                    LibBridgeProcess: libProcess.address,
                    LibBridgeRetry: libRetry.address,
                    LibTrieProof: libTrie.address,
                },
            })
        ).deploy()
        await bridge.init(addressManager.address)

        // dummy struct to test with
        testMessage = {
            id: 1,
            sender: signers[0].address,
            srcChainId: 1,
            destChainId: 2,
            owner: signers[0].address,
            to: signers[1].address,
            refundAddress: signers[0].address,
            depositValue: 0,
            callValue: 0,
            processingFee: 0,
            gasLimit: 0,
            data: "0x",
            memo: "",
        }

        testTypes = [
            "uint256",
            "address",
            "uint256",
            "uint256",
            "address",
            "address",
            "address",
            "uint256",
            "uint256",
            "uint256",
            "uint256",
            "bytes",
            "string",
        ]

        testVar = [
            1,
            signers[0].address,
            1,
            2,
            signers[0].address,
            signers[1].address,
            signers[0].address,
            0,
            0,
            0,
            0,
            "0x",
            "",
        ]
    })

    describe("LibBridgeData", async function () {
        before(async function () {
            libData = await (
                await ethers.getContractFactory("TestLibBridgeData")
            ).deploy()
        })

        it("should return properly hashed message", async function () {
            const hashed = await libData.hashMessage(testMessage)
            // console.log(await libData.test(testMessage))
            // const utilHash = await ethers.utils.keccak256(
            // )
            // const utilHash = await ethers.utils.defaultAbiCoder.encode(
            //     testTypes,
            //     testVar
            // )
            // console.log(utilHash)
            const utilHash = await web3.eth.abi.encodeParameters(
                testTypes,
                testVar
            )
            console.log(utilHash)

            expect(hashed)
        })
    })
    // abi.encode("TAIKO_BRIDGE_MESSAGE")
    // 0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000145441494b4f5f4252494447455f4d455353414745000000000000000000000000
    // abi.encode(message)
    // 0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f800000000000000000000000073bdc7fa05fb104d542140ef1a3d1c60d2139e730000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    // abi.encode("TAIKO_BRIDGE_MESSAGE", message)
    // 0x0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000145441494b4f5f4252494447455f4d45535341474500000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f800000000000000000000000073bdc7fa05fb104d542140ef1a3d1c60d2139e730000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
    // abi.encode("TAIKO_BRIDGE_MESSAGE", abi.encode(message))
    // 0x0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000145441494b4f5f4252494447455f4d4553534147450000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f800000000000000000000000073bdc7fa05fb104d542140ef1a3d1c60d2139e730000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

    // ethers.utils.defaultAbiCoder.encode(testTypes, testVar)
    // 0x00000000000000000000000000000000000000000000000000000000000000010000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f800000000000000000000000073bdc7fa05fb104d542140ef1a3d1c60d2139e730000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

    // web3.eth.abi.encodeParameters(testTypes, testVar)
    // 0x00000000000000000000000000000000000000000000000000000000000000010000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f800000000000000000000000073bdc7fa05fb104d542140ef1a3d1c60d2139e730000000000000000000000004d9e82ac620246f6782eaabac3e3c86895f3f0f8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
})
