// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Deployers} from "@uniswap/v4-core/test/utils/Deployers.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {PoolSwapTest} from "v4-core/test/PoolSwapTest.sol";
import {LiquidationHook} from "../src/LiquidationHook.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";
import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {NaiveOracle} from "../src/NaiveOracle.sol";
import {IPool, Junlend} from "../src/Junlend.sol";
import {HookMiner} from "./HookMiner.sol";

interface ITestnetERC20 {
    function mint(address token, address to, uint256 amount) external;
}

contract LiquidationHookTest is Test, Deployers {
    using CurrencyLibrary for Currency;
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;
    using BalanceDeltaLibrary for BalanceDelta;

    LiquidationHook hook;

    NaiveOracle public oracle;
    Junlend public junlend;

    uint256 mainnetFork;

    IPool private constant pool =
        IPool(0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951);
    IERC20 public constant wbtc =
        IERC20(0x29f2D40B0605204364af54EC677bD022dA425d03);
    IERC20 public constant awbtc =
        IERC20(0x1804Bf30507dc2EB3bDEbbbdd859991EAeF6EefF);
    IERC20 public constant usdc =
        IERC20(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8);
    IERC20 public constant ausdc =
        IERC20(0x16dA4541aD1807f4443d92D26044C1147406EB80);

    function setUp() public {
        mainnetFork = vm.createSelectFork("https://1rpc.io/sepolia");

        oracle = new NaiveOracle();
        junlend = new Junlend(address(oracle));
        wbtc.approve(address(pool), type(uint256).max);
        awbtc.approve(address(junlend), type(uint256).max);
        usdc.approve(address(junlend), type(uint256).max);
        ITestnetERC20(0xC959483DBa39aa9E78757139af0e9a2EDEb3f42D).mint(
            address(wbtc),
            address(this),
            100e8
        );

        // migrate
        pool.supply(address(wbtc), 1e8, address(this), 0);
        pool.borrow(address(usdc), 10_000e6, 2, 0, address(this));
        junlend.migrate(awbtc, usdc);

        // uniswap
        deployFreshManagerAndRouters();
        deployMintAndApprove2Currencies();
        uint160 flags = uint160(
            Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_SWAP_FLAG
        );

        address CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
        (address hookAddress, bytes32 salt) = HookMiner.find(
            CREATE2_DEPLOYER,
            flags,
            type(LiquidationHook).creationCode,
            abi.encode(address(manager), address(junlend))
        );
        console.log(hookAddress);
        hook = new LiquidationHook{salt: salt}(manager, junlend);
    }

    function testHookLiquidation() public {
        console.log(junlend.getHealthFactor(address(this))); // 4.5
        oracle.setPrice(13300e18);
        console.log(junlend.getHealthFactor(address(this))); // 0.9975
        swapRouter.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100e6,
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            PoolSwapTest.TestSettings({
                takeClaims: false,
                settleUsingBurn: false
            }),
            ""
        );
        console.log(junlend.getHealthFactor(address(this))); // 0.99998
        swapRouter.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100e6,
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            PoolSwapTest.TestSettings({
                takeClaims: false,
                settleUsingBurn: false
            }),
            ""
        );
        console.log(junlend.getHealthFactor(address(this))); // 1.0025
        vm.expectRevert();
        swapRouter.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: -100e6,
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            PoolSwapTest.TestSettings({
                takeClaims: false,
                settleUsingBurn: false
            }),
            ""
        );
    }
}
