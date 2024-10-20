// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract NaiveOracle {
    // 1 BTC is $60,000
    uint256 public price = 60_000e18;

    function setPrice(uint256 _price) external {
        price = _price;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }
}
