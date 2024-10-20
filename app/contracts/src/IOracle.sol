interface IOracle {
    function setPrice(uint256 _price) external;

    function getPrice() external view returns (uint256);
}
