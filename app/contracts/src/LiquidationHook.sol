pragma solidity ^0.8.26;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
import {PoolManager} from "v4-core/PoolManager.sol";
import {PoolId} from "v4-core/types/PoolId.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {TransientStateLibrary} from "v4-core/libraries/TransientStateLibrary.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {BeforeSwapDelta, toBeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Junlend} from "src/Junlend.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";

contract LiquidationHook is BaseHook {
    error DoNotAddLiquidity();

    Junlend public junlend;

    constructor(
        IPoolManager _poolManager,
        Junlend _junlend
    ) BaseHook(_poolManager) {
        junlend = _junlend;
    }

    function setJunlend(Junlend _junlend) external {
        junlend = _junlend;
    }

    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return
            Hooks.Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: true,
                beforeRemoveLiquidity: false,
                afterAddLiquidity: false,
                afterRemoveLiquidity: false,
                beforeSwap: true,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta: false,
                afterSwapReturnDelta: false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta: false
            });
    }

    function beforeAddLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        revert DoNotAddLiquidity();
    }

    function beforeSwap(
        address /* sender **/,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata /* hookData **/
    )
        external
        override
        onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        (
            Currency inputCurrency,
            Currency outputCurrency,
            uint256 amount
        ) = _getInputOutputAndAmount(key, params);

        poolManager.take(inputCurrency, address(this), amount);
        uint256 amountToWithdraw = junlend.liquidate(msg.sender, amount);
        poolManager.sync(outputCurrency);
        outputCurrency.transfer(address(poolManager), amountToWithdraw);
        poolManager.settle();

        // no-op
        BeforeSwapDelta hookDelta = toBeforeSwapDelta(
            int128(-params.amountSpecified),
            int128(params.amountSpecified)
        );
        return (IHooks.beforeSwap.selector, hookDelta, 0);
    }

    function _getInputOutputAndAmount(
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params
    ) internal pure returns (Currency input, Currency output, uint256 amount) {
        (input, output) = params.zeroForOne
            ? (key.currency0, key.currency1)
            : (key.currency1, key.currency0);

        amount = params.amountSpecified < 0
            ? uint256(-params.amountSpecified)
            : uint256(params.amountSpecified);
    }
}
