// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "test/shared/DeployCapability.sol";
import "test/shared/thirdparty/Multicall3.sol";
import "../../contracts/shared/bridge/IBridge.sol";

contract RecallMessage is DeployCapability {
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    modifier broadcast() {
        require(privateKey != 0, "invalid private key");
        vm.startBroadcast(privateKey);
        _;
        vm.stopBroadcast();
    }

    function run() external broadcast {
        IBridge.Message memory message = IBridge.Message({
            id: 1_636_356,
            fee: 0,
            gasLimit: 3_000_000,
            from: 0x1D2D1bb9D180541E88a6a682aCf3f61c1605B190,
            srcChainId: 17_000,
            srcOwner: 0x1D2D1bb9D180541E88a6a682aCf3f61c1605B190,
            destChainId: 167_009,
            destOwner: 0x95F6077C7786a58FA070D98043b16DF2B1593D2b,
            to: 0x95F6077C7786a58FA070D98043b16DF2B1593D2b,
            value: 0,
            data: hex"7f07c947000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000005c000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ca11bde05977b3631167028862be2a173976ca110000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000004e482ad56cb0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000016700900000000000000000000000000000100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000243659cfe6000000000000000000000000637b1e6e71007d033b5d4385179037c90665a2030000000000000000000000000000000000000000000000000000000000000000000000000000000016700900000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000243659cfe600000000000000000000000050216f60163ef399e22026fa1300aea8eeba34620000000000000000000000000000000000000000000000000000000000000000000000000000000016700900000000000000000000000000000100020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000243659cfe60000000000000000000000001063f4cf9eaaa67b5dc9750d96ec0bd885d10aee0000000000000000000000000000000000000000000000000000000000000000000000000000000016700900000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000243659cfe60000000000000000000000001063f4cf9eaaa67b5dc9750d96ec0bd885d10aee000000000000000000000000000000000000000000000000000000000000000000000000000000001670090000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000064d8f4648f0000000000000000000000000000000000000000000000000000000000028c61627269646765645f6572633230000000000000000000000000000000000000000000000000000000000000001baf1ab3686ace2fd47e11ac627f3cc626aec0ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        });
        //        bytes32 msgHash =
        // IBridge(0xA098b76a3Dd499D3F6D58D8AcCaFC8efBFd06807).hashMessage(message);
        //        console2.logBytes32(msgHash);

        IBridge(0xA098b76a3Dd499D3F6D58D8AcCaFC8efBFd06807).recallMessage(
            message,
            hex"0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000028c6100000000000000000000000000000000000000000000000000000000002f2124e1ae759e9a90eebbcfba5a6d81ba080f6a37215e11279dc5107e11e89e32fad4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000010c0000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000058000000000000000000000000000000000000000000000000000000000000007c00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000c400000000000000000000000000000000000000000000000000000000000000e600000000000000000000000000000000000000000000000000000000000000f400000000000000000000000000000000000000000000000000000000000000214f90211a0b261e58ef55b23c1516b4147913eb08c67aa94cf2d4006954ccc23e653093acfa00629bc7d4a2a1bdac0b3f243b354db691b79eb435a5388013212b44f5486c07aa073519fc438c75fecd81d087f074556335d4dbbd162524f9283a6f22041b099a7a04844431a0437bd81a3ca06dbd472a1751f3e671604f9619a0b2049864762de93a0f50f6f3c9971ea4711ca26651175bd1ca701d911665ddca8785a41c7664b6a9aa00b2301c2ad63e45848e99d7f5092c35fe8f7219e6241843a0974c4dd43ddffd8a03269bf9ee1265dc9e03968e8c561551bdc727e240f7c8feec45e11da7dee4b8ba087e49f4083bb559668502cbdddcfef37e6c04b28078e16e4d35657d2a47ac947a09f81bc98e198cccf01d1b45d4adfbeffaed40739ddcd15e5a680a0932294d01ea02671b6078ad60a51b1872e7340504dc0eb2f6b9436f76b1747f938620245a309a02372744c256a3070965b001be3027c829743308b79f9920b903338abd77c03c0a07a52c9d114dad3d9f401d2ce82480a21dce02d2729c591fa54518de7d98dec73a0ddc6f3b8fb2b44e207ae68d89cbfc114667787c977c5d4672881ec491ec81f2da09653af0e607a25069e1bcdb3b39c28fd4126ae7b82b5670b23bb9163bf89af83a0117fa323afc2e251200b12b3de176edafd2c781e654cb062fa16d6ed7ef3cdd0a057304aec0d5e5c1127831bb1b8718f68b2d061688c579264a48ed731587e66ca800000000000000000000000000000000000000000000000000000000000000000000000000000000000000214f90211a06a8c2fb6fb670873aa18ce4258fd47ae2b12b7799bc4ab82786200a4f1c17879a0bdd9a3ea4993f8281892ba205305cb92bb568d6ef1d6e41304b9f95813ce2b64a0f902aaa74f8b8bef0bf0848ac6417f34d70efa1a73b7330e0e91fa924979981da0b864f3b27d5008af514de46419c5aa699d90e84019c070b6482ee8fcae77a1c5a0ef55a9413d324ce11ae759eb9e862dfca750585f84bfaeb6f034d80080123dc7a0dbb8614f7e67c438f3dce01d744b30645c465b2930f9e3c8a7f593185f8bc5aba07943ae9ed918c0bb6dff64bc2c789c2040519aadf39aba211963947c882fefc0a0b27175fb3593b64946340159770c0147b9b53f8e10ea6cbd5caac01cd943bad8a05314abe22612badf8837f2cbcaf1ba789862f42938dcc74f7a1cce4c26bcfacca09bca222b5f7119a903499d52312c92b68715c9c3020e28acb626d5e8391cb1f8a049bcfa300c07314770738ceb8ea69ac123b4770c24a24f5b4047ace232933d2ca040363db45476d6f2815e2253af67f3b9914f860637e56ea9f43541ab61995685a0c72dda8c90cadcddd57365d71c673b9e06938a2dba8c633028041cd2c04da45ba012b15560d1e31946fae2923d44686bd64cafeab88a51f138feef8ef3269db95aa080651de779745703e4577ec96265a4883a056c9e28dec401c3e5d5fcbc325125a0e552e910f03f38e6c8c8e31c52ee9c8947f0bd66712f089af1c3cfce22c680a5800000000000000000000000000000000000000000000000000000000000000000000000000000000000000214f90211a074e0cdcf9e74c02cd9d049909feccd7ca1e2a8af8fd64ed6aed4f529c2957378a0c4fca13e297761e8da0a94b7bac029f7b7e422e6a62ce495df187d77b420e3caa0285a11fe3d9dccba40c7912208b3f9150774d38374a97f64bd0d92ec0b0d7eaea0a746daca61d69face8993a5bdc1f282ae5de5d6033b5bbf89687e4fe6c862ebba09a4f303fc29e57002d617a990f75ac727470a5330c36f43f0c922daab60d9ed6a0d1067e0c236dcf99e7181b3587de74c2f5f600aaa97960a60a8aeb92756d187ea08f48c557d4c9b86c35ce7e891e5b58657bb6e434e54054081e90b538671ecd91a08d26cfffca1d048494df43e12b8656145fd8a830ee111f8b1085d7f276bd505da0a9175a6c918d784d8fe21292cc4c0b3d3973c2e60a369ce75d8d29b2bce6e3c8a06c96e9c05151976a034b7f597be12a84d4dc6534bcd8705e66103b489f22ef47a0ba114dce87cfa47ccd5b3bfc7871af482e0aa7ab8e767170b6d68f7479258ca2a021717847c01385c92361551d3cfb6903a18b340bf755f1087958cb79393993b0a03dce2bb8ac96bbb5c99c2ae544af9a2fa6f94d238533710cb9234382ea2ed287a022cf21f637d1d33148c61fbb36500e36a6737f6dc19b31e758c5e7ee23078b60a0e9ecca0eb5891a68b5a438acbcbc0294c83023e53017e4f2a82a5c2e690aa95ea094834e39a374c72cbb3221db51eade1de673a84e0fc6f432830e2f124fd45ed4800000000000000000000000000000000000000000000000000000000000000000000000000000000000000214f90211a0c99018585778954e4374ee45e632c1112f7a5a36f6d2fc41526375d9aa74d14fa00f7392a43069632e2f30e51154705239d966c612aacef5b41f514103c2ce2740a01141d713a9f18fb6e097b63677209b4bef13b86762cb7b7ece356e7d4849c112a00151b2c8e1ee5f830641c6206f332a7d1763861b0146f8b28787f62f2e520527a06734daf44731540a3f5b22ca5939eb69ba3b4a5371b65550160616592b7291f8a098555f43ed3c86cc45e7273984e648bbda191d441e540029d6a3739b6db342c0a0a9fb320d3b21d8fecf2189c4dfc3ddc0d4e3a8dab92e901541e189c2ee1de241a0926e4bd52580a59ec3c8e103d302648ccc532eb4bf33df51086228a3395607c4a037179636bd3a2c04af6f12b6d8635304be6ff62597cabe102fc58d7b79bebb52a01c5eed7f22ae5920ae138414e87f2b457b9fd73218f91802dc0514e25ce5e0e3a02e62a78113a297f7437b6d1e4f28b26743ad2956c25d1832696e41e15a14e53ea08e81596dcb24c74822ce82bd12af33df660aaee0eccdf2ad589c3dd25531461ca0a3673a93ef754805d716493eea55f9239f4beadcb8b31679e1557127c5767c5aa06b6fbcc563932faaae49f0e2389446e6645a010b7171cd90f9871033fb38e7aba0941789efca27746bc4ec277675ebf3f89a562e9efa934fae6fb2e75360386392a0a723d962b9052e797293cc71e9e6c23e9f8645a7d453334bfbb6dc34827a7387800000000000000000000000000000000000000000000000000000000000000000000000000000000000000214f90211a027eb7a6f3ea4d2c8b9d38efd48201d68b0ac8c7ed9e73f53bb07ff9e7d63e354a02ec954c9a26236c373d4497a4a628f86887ea3daedf5dcdc95b7112edeaeb408a0a68c7b0b54d7f6a1f12a0145ccade053f8d5d925bb1e604d69670c5e733d9c49a0de82861066c53b19e3160af71d613b8a1aea3335d7fed2f348eb5e9369d04d59a0902b18205558e460a65e5939bdaf6051336db2a9ffb5a3c7e21999c850f4eec6a090556ba5aab84a97d511871f9661f87dcdeb865db06ece920ce611f7b05da294a0d1efcd04085407a3d5759070a6fc70b367e394819c9c04696832a6d5f0ed31c7a08f12623ab55f9afbe76f720622c1a33064a26e1acc6ccbaf0f7f80cf707a08c3a03ae77588ee5bcb6a4c4d2d84d7603a55dd3c83303402e59224ce97b197d86ae2a044d1f12eaaa5d864416d37ca8e2e250c8a720f5825dee79ac966417467d8ff57a04ad4395e4c9ffda889595808cb6b8f711bd2d77e340e3033a2ae5fb1caa5e34ca0bca916230e1afbb2dd750239191a20215dd6f8849b6724390313768464b50263a055acf9c331ba105201920b45f48d7233141d455a2ff9af194a9deb02176f4cf3a03be2fd22fdb0b012b1c6e96c4b0fa9b43765811731ca82d16c2eb52c78cf5eaba0276128452968ff14654a5d3f97ae8e28b293014dcfa6cc5e6977da689fd9dd7ca09229e7ca9bf13aea6625b9609f0bcfdabadd0ad201530989090d23716d98c0418000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f4f901f1a0c3c0541a35b174c228c108830d7bd901311308322388176812b6c8a1b71c4289a034e257231eb225d76ec3d07aaf02e5664587abdf65b9210e0e7742fcb2c21eeaa0c1630988c43a4322ea847641a419f26d633cca6012698f14de6fee03382f2996a0e36eb3f1d4da6969b3de96caace5489300c73cf93c93a5b9a66951961f786163a0c12d004f0967a95207b62b5e5e1ffce6988a510049f2b0c9eeaa6ea9ad1af2a480a02d17006a54f6dbc156d81831e9ff7f2a586a20456b32f95e32ca24e59de19d80a0565e510f92d138046a86fca49336de6298503a1c3dfcc26326389cd4d2e04de4a09ccf8cdc766d7377276c5c851c219b76492e7a637a275a6b113b871551388101a0a099517d54351c27357866ecdfe6d27c9a88aa5859d79566238d65963bc05f3fa087a5c5521052ca9367659b8b2cf499f39f2b02e92a457beb5486350575b47621a086566992ffd421e29101492b624db3645d70a949249f149c00e472d3f7785e62a0a8100550216d044f8dc9266114a0f52286bd757abb6f3c624308858e507ba407a0117529c6c0730fb56ead6b1b32937fec3e226aa3af99f2a127b90ec0f3a55473a003db4763499a91560381aba504c010bfa67a51fedef49bbd194e79f12ce03090a0772a5d96f875061f4ae59f0f9255b5e381256266e91ca482f799ab4c34d6abf68000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b3f8b180a06a822895b6581263680a6f45b0eeb4aaeb0532d2afa696969f1cd9c1e1fc2d76a0910425a47d55a473e49899d6f11e04a3f944f8b2756b62df8c09484feb426198a050a85d1b66bdb0bdf7747e1372b82ee9168ca512fe235589f1ec4ad844e1b12180808080808080a03b914a76539eba743db1c093afff1e1ca132b2b5ef30db35f65d8090cc6d8d38a0561eda19db9c00872ea36a6bb383dab2fdfdf18a0945ec11460369a171c3bc1d80808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000071f86f9d37ae81a58eb98d9c78de4a1fd7fd9535fc953ed2be602daaa41767312ab84ff84d808908a80c906c2f025519a056e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421a0c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a4700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
    }
}
