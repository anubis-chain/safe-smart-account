// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import {Script, console} from "forge-std/Script.sol";

import {Safe} from "@safe-global/safe-smart-account/contracts/Safe.sol";
import {SafeL2} from "@safe-global/safe-smart-account/contracts/SafeL2.sol";
import {SafeProxyFactory} from "@safe-global/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";
import {MultiSend} from "@safe-global/safe-smart-account/contracts/libraries/MultiSend.sol";
import {MultiSendCallOnly} from "@safe-global/safe-smart-account/contracts/libraries/MultiSendCallOnly.sol";
import {TokenCallbackHandler} from "@safe-global/safe-smart-account/contracts/handler/TokenCallbackHandler.sol";
import {
    CompatibilityFallbackHandler
} from "@safe-global/safe-smart-account/contracts/handler/CompatibilityFallbackHandler.sol";
import {
    ExtensibleFallbackHandler
} from "@safe-global/safe-smart-account/contracts/handler/ExtensibleFallbackHandler.sol";
import {SignMessageLib} from "@safe-global/safe-smart-account/contracts/libraries/SignMessageLib.sol";
import {CreateCall} from "@safe-global/safe-smart-account/contracts/libraries/CreateCall.sol";
import {SafeToL2Setup} from "@safe-global/safe-smart-account/contracts/libraries/SafeToL2Setup.sol";
import {SafeMigration} from "@safe-global/safe-smart-account/contracts/libraries/SafeMigration.sol";
import {SimulateTxAccessor} from "@safe-global/safe-smart-account/contracts/accessors/SimulateTxAccessor.sol";

/**
 * @title DeploySafe
 * @notice Deploys the full Safe v1.5.0 contract suite onto Anubis Chain.
 *         Anubis does not yet have Safe's singleton factory, so these test
 *         deployments use non-canonical addresses.
 *
 * Usage:
 *   DEPLOYMENT_ENV=test DEPLOYMENT_OUTPUT=deployments/6714/test/safe-v1.5.0.json \
 *     forge script script/DeploySafe.s.sol:DeploySafe \
 *     --rpc-url <rpc> --broadcast --private-key <key>
 */
contract DeploySafe is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory json = "deployment";

        console.log("=== Anubis Safe v1.5.0 test deployment (non-canonical addresses) ===");
        vm.startBroadcast(pk);

        address singleton = address(new Safe());
        _record(json, "Safe", singleton);
        address singletonL2 = address(new SafeL2());
        _record(json, "SafeL2", singletonL2);
        _record(json, "SafeProxyFactory", address(new SafeProxyFactory()));
        _record(json, "TokenCallbackHandler", address(new TokenCallbackHandler()));
        _record(json, "MultiSend", address(new MultiSend()));
        _record(json, "MultiSendCallOnly", address(new MultiSendCallOnly()));
        address fallbackHandler = address(new CompatibilityFallbackHandler());
        _record(json, "CompatibilityFallbackHandler", fallbackHandler);
        _record(json, "ExtensibleFallbackHandler", address(new ExtensibleFallbackHandler()));
        _record(json, "SignMessageLib", address(new SignMessageLib()));
        _record(json, "CreateCall", address(new CreateCall()));
        _record(json, "SafeToL2Setup", address(new SafeToL2Setup()));
        _record(json, "SafeMigration", address(new SafeMigration(singleton, singletonL2, fallbackHandler)));
        _record(json, "SimulateTxAccessor", address(new SimulateTxAccessor()));

        vm.stopBroadcast();

        vm.serializeUint(json, "chainId", _chainId());
        vm.serializeBool(json, "canonical", false);
        vm.serializeString(json, "environment", vm.envString("DEPLOYMENT_ENV"));
        string memory out = vm.serializeString(json, "version", "1.5.0");
        vm.writeJson(out, vm.envString("DEPLOYMENT_OUTPUT"));
    }

    function _record(string memory json, string memory name, address deployed) private {
        console.log(name, deployed);
        vm.serializeAddress(json, name, deployed);
    }

    function _chainId() private pure returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }
}
