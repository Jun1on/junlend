// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

interface IChronicleOracle {
    function latestAnswer() external view returns (uint256);
}

// returns the BTC price or spoofed price (for testing)
contract NaiveOracle {
    uint256 public manualPrice = 0;

    IChronicleOracle public oracle =
        IChronicleOracle(0x6edF073c4Bd934d3916AA6dDAC4255ccB2b7c0f0);

    function setPrice(uint256 _manualPrice) external {
        manualPrice = _manualPrice;
    }

    function getPrice() external view returns (uint256) {
        if (manualPrice > 0) {
            return manualPrice;
        } else {
            return oracle.latestAnswer();
        }
    }
}
