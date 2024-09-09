// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "../test/DeployCapability.sol";
import "../contracts/L2/DelegateOwner.sol";

//  forge script --rpc-url  https://rpc.mainnet.taiko.xyz script/DeployL2DelegateOwner.s.sol
contract DeployL2DelegateOwner is DeployCapability {
    address public l2Sam = 0x1670000000000000000000000000000000000006;
    address public testAccount2 = 0x3c181965C5cFAE61a9010A283e5e0C1445649810; // owned by Daniel W

    address public l1Owner = testAccount2;
    address public l2Admin = testAccount2;

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function run() external broadcast {
        deployProxy({
            name: "delegate_owner",
            impl: address(new DelegateOwner()),
            data: abi.encodeCall(DelegateOwner.init, (l1Owner, l2Sam, 1, l2Admin))
        });
    }
}
