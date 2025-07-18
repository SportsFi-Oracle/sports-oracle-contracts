// Subscriber Contract (On any EVM chain)
import "./interfaces/IZKPricePublisher.sol";

contract ZKPriceSubscriber {
    IZKPricePublisher public publisher;
    mapping(bytes32 => uint256) public prices;

    function updatePrice(bytes32 assetID) external payable {
        // Fetch latest price from publisher (optimistic)
        (uint256 price, uint256 timestamp) = publisher.getLatestUpdate(assetID);
        
        // Cross-chain ZK proof can be verified lazily (see Section 3)
        prices[assetID] = price;
    }
}