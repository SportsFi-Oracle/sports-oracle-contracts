// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SXPriceOracle {
    address public owner;
    mapping(bytes32 => uint256) public prices; // Store prices by asset symbol
    uint256 public lastUpdated; // Timestamp of the last update

    // Event to log price updates
    event PriceUpdated(string indexed asset, uint256 price, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender; // Set the contract deployer as the owner
    }

    // Function to update prices (onlyOwner can call this)
    function updatePrice(string memory asset, uint256 price) public onlyOwner {
        require(price > 0, "Price must be greater than zero");
        bytes32 assetKey = keccak256(abi.encodePacked(asset));
        prices[assetKey] = price;
        lastUpdated = block.timestamp;
        emit PriceUpdated(asset, price, block.timestamp);
    }

    // Public function to retrieve the latest price
    function getPrice(string memory asset) public view returns (uint256) {
        bytes32 assetKey = keccak256(abi.encodePacked(asset)); // Hash the asset string
        require(prices[assetKey] != 0, "Price not available");
        return prices[assetKey];
    }
}
