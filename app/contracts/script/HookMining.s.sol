// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {PoolManager} from "v4-core/PoolManager.sol";
import {PoolSwapTest} from "v4-core/test/PoolSwapTest.sol";
import {PoolModifyLiquidityTest} from "v4-core/test/PoolModifyLiquidityTest.sol";
import {PoolDonateTest} from "v4-core/test/PoolDonateTest.sol";
import {PoolTakeTest} from "v4-core/test/PoolTakeTest.sol";
import {PoolClaimsTest} from "v4-core/test/PoolClaimsTest.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {HookMiner} from "../test/HookMiner.sol";
import {LiquidationHook} from "../src/LiquidationHook.sol";
import "forge-std/console.sol";

contract HookMiningSample is Script {
    PoolManager manager =
        PoolManager(0xCa6DBBe730e31fDaACaA096821199EEED5AD84aE);
    PoolSwapTest swapRouter =
        PoolSwapTest(0xEc9537B6D66c14E872365AB0EAE50dF7b254D4Fc);
    PoolModifyLiquidityTest modifyLiquidityRouter =
        PoolModifyLiquidityTest(0x1f03f235e371202e49194F63C7096F5697848822);

    function setUp() public {
        uint160 flags = Hooks.BEFORE_INITIALIZE_FLAG;

        address CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
        (address hookAddress, bytes32 salt) = HookMiner.find(
            CREATE2_DEPLOYER,
            flags,
            type(LiquidationHook).creationCode,
            abi.encode(address(manager))
        );

        vm.startBroadcast();
        LiquidationHook hook = new LiquidationHook{salt: salt}(manager);
        require(address(hook) == hookAddress, "hook address mismatch");
        vm.stopBroadcast();
    }

    function run() public {}
}
