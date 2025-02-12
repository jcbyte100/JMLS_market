pragma solidity ^0.5.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";
import "./JMLSAuction.sol";

contract JMLSMarket is ERC721Full, Ownable {

    constructor() ERC721Full("JMLSMarket", "JMLS") public {}

    using Counters for Counters.Counter;

    Counters.Counter token_ids;

    address payable foundation_address = msg.sender;

    mapping(uint => JMLSAuction) public auctions;

    modifier propertyRegistered(uint token_id) {
        require(_exists(token_id), "Property not registered!");
        _;
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new JMLSAuction(foundation_address);
    }

    function registerProperty(string memory uri) public payable onlyOwner {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(foundation_address, token_id);
        _setTokenURI(token_id, uri);
        createAuction(token_id);
    }

    function endAuction(uint token_id) public onlyOwner propertyRegistered(token_id) {
        JMLSAuction auction = auctions[token_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        JMLSAuction auction = auctions[token_id];
        return auction.ended();
    }

    function highestBid(uint token_id) public view propertyRegistered(token_id) returns(uint) {
        JMLSAuction auction = auctions[token_id];
        return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view propertyRegistered(token_id) returns(uint) {
        JMLSAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint token_id) public payable propertyRegistered(token_id) {
        JMLSAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }

}
