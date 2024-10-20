// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {console} from "forge-std/Test.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
}

interface IVault {
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}

interface IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}

contract Migrator is IFlashLoanRecipient {
    IVault private constant vault =
        IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IPool private constant pool =
        IPool(0x4e033931ad43597d96D6bcc25c280717730B58B1);
    IERC20 public constant wbtc =
        IERC20(0x29f2D40B0605204364af54EC677bD022dA425d03);
    IERC20 public constant awbtc =
        IERC20(0x1804Bf30507dc2EB3bDEbbbdd859991EAeF6EefF);
    IERC20 public constant usdc =
        IERC20(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8);
    IERC20 public constant ausdc =
        IERC20(0x16dA4541aD1807f4443d92D26044C1147406EB80);

    constructor() payable {
        wbtc.approve(address(pool), type(uint256).max);
        usdc.approve(address(pool), type(uint256).max);
    }

    function migrate(address collateral, address debt) external {
        // IERC20[] memory assets = new IERC20[](1);
        // assets[0] = wsteth;
        // uint256[] memory amounts = new uint256[](1);
        // amounts[0] = SUPPLY_AMOUNT;
        // vault.flashLoan(this, assets, amounts, abi.encode(amount));
    }

    function receiveFlashLoan(
        IERC20[] memory,
        uint256[] memory,
        uint256[] memory,
        bytes memory userData
    ) external override {
        require(msg.sender == address(vault));
    }
}
