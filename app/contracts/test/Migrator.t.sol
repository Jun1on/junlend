// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPool, Migrator} from "../src/Migrator.sol";

interface ITestnetERC20 {
    function mint(address token, address to, uint256 amount) external;
}

contract MigratorTest is Test {
    Migrator public migrator;

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
        migrator = new Migrator();
        wbtc.approve(address(pool), type(uint256).max);
        awbtc.approve(address(migrator), type(uint256).max);
        ITestnetERC20(0xC959483DBa39aa9E78757139af0e9a2EDEb3f42D).mint(
            address(wbtc),
            address(this),
            100e8
        );
    }

    function testMigrate() public {
        pool.supply(address(wbtc), 1e8, address(this), 0);
        pool.borrow(address(usdc), 10_000e6, 2, 0, address(this));
        migrator.migrate(awbtc, usdc);
    }
}
