// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces/IVerifier.sol";
contract OptimisticZKPriceOracle {
    address public owner;
    mapping(bytes32 => uint256) public prices;
    mapping(bytes32 => uint256) public pendingPrices; // Optimistic updates
    mapping(bytes32 => uint256) public lastVerified; // Timestamp of last ZK verification
    
    IVerifier public verifier;
    uint256 public challengeWindow = 30 minutes; // Time to dispute prices
    
    event PriceUpdatedOptimistically(string indexed asset, uint256 price, uint256 timestamp);
    event PriceVerified(string indexed asset, uint256 price, uint256 timestamp);
    event PriceDisputed(string indexed asset, uint256 submittedPrice, uint256 disputedPrice);

    constructor(address _verifierAddress) {
        owner = msg.sender;
        verifier = IVerifier(_verifierAddress);
    }

    // 1. Optimistic Update (Low Gas)
    function updatePriceOptimistic(string memory asset, uint256 price) external onlyOwner {
        bytes32 assetKey = keccak256(abi.encodePacked(asset));
        pendingPrices[assetKey] = price;
        emit PriceUpdatedOptimistically(asset, price, block.timestamp);
    }

    // 2. ZK Verification Trigger (High Gas - Only Called at Critical Moments)
    function verifyPrice(
        string memory asset,
        uint256 pendingPrice,
        uint256 verifiedPrice,
        uint256 timestamp,
        bytes calldata zkProof
    ) external {
        bytes32 assetKey = keccak256(abi.encodePacked(asset));
        require(pendingPrices[assetKey] == pendingPrice, "Invalid pending price");
        
        // Verify ZK proof matches pendingPrice → verifiedPrice transition
        _verifyProof(assetKey, pendingPrice, verifiedPrice, timestamp, zkProof);
        
        // Finalize if valid
        prices[assetKey] = verifiedPrice;
        lastVerified[assetKey] = block.timestamp;
        emit PriceVerified(asset, verifiedPrice, block.timestamp);
    }

    // 3. Dispute Mechanism (Slash Bad Actors)
    function disputePrice(
        string memory asset,
        uint256 disputedPrice,
        uint256 correctPrice,
        bytes calldata zkProof
    ) external {
        bytes32 assetKey = keccak256(abi.encodePacked(asset));
        require(block.timestamp - lastVerified[assetKey] <= challengeWindow, "Challenge window closed");
        
        // Verify the dispute proof
        _verifyProof(assetKey, disputedPrice, correctPrice, block.timestamp, zkProof);
        
        // Penalize owner and reward disputer (simplified)
        prices[assetKey] = correctPrice;
        emit PriceDisputed(asset, disputedPrice, correctPrice);
    }

    // 4. Critical System Actions Require Recent Verification
    modifier checkFreshPrice(string memory asset) {
        bytes32 assetKey = keccak256(abi.encodePacked(asset));
        require(block.timestamp - lastVerified[assetKey] <= 24 hours, "Price stale - verification required");
        _;
    }

    function mint(address user, string memory asset, uint256 amount) external checkFreshPrice(asset) {
        // Uses last verified price
        uint256 price = prices[keccak256(abi.encodePacked(asset))];
        _mint(user, amount * price);
    }
}