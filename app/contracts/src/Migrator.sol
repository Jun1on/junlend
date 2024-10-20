// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {console} from "forge-std/Test.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

interface IPool {
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function repay(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        address onBehalfOf
    ) external;
}
import {TransientStateLibrary} from "@uniswap/v4-core/src/libraries/TransientStateLibrary.sol";

contract Migrator {
    using TransientStateLibrary for IPoolManager;
    IPoolManager private constant manager =
        IPoolManager(0x8C4BcBE6b9eF47855f97E675296FA3F6fafa5F1A);
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
    uint256 public constant FLASHLOAN_AMOUNT = 10_000e6;

    constructor() {
        wbtc.approve(address(pool), type(uint256).max);
        usdc.approve(address(pool), type(uint256).max);
    }

    function migrate(IERC20 collateral, IERC20 debt) external {
        manager.unlock(abi.encode(msg.sender, collateral, debt));
    }

    function unlockCallback(
        bytes calldata data
    ) external returns (bytes memory) {
        require(msg.sender == address(manager));
        (address sender, IERC20 collateral, IERC20 debt) = abi.decode(
            data,
            (address, IERC20, IERC20)
        );
        manager.take(
            Currency.wrap(address(debt)),
            address(this),
            FLASHLOAN_AMOUNT
        );
        // migrate user position
        pool.repay(address(debt), FLASHLOAN_AMOUNT, 2, sender);
        uint256 amountRepayed = FLASHLOAN_AMOUNT -
            debt.balanceOf(address(this));
        collateral.transferFrom(
            sender,
            address(this),
            collateral.balanceOf(sender)
        );
        pool.borrow(address(debt), amountRepayed, 2, 0, address(this));
        // repay flashloan
        manager.sync(Currency.wrap(address(debt)));
        debt.transfer(address(manager), FLASHLOAN_AMOUNT);
        manager.settle();
        return bytes("");
    }
}
