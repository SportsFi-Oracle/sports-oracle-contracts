// filepath: /home/boltik/code/sports-oracle-contracts/contracts/IZKPricePublisher.sol
pragma solidity ^0.8.0;

interface IZKPricePublisher {
    function getLatestUpdate(bytes32 assetID) external view returns (uint256 price, uint256 timestamp);
}