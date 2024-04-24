// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./PriceFeed.sol";

error FUNDME_NOT_AUTHORIZED();
error FUNDME_BELOW_MINIMUM();
error FUNDME_FAILED_WITHDRAW();

contract FundMe {

    using PriceFeed for uint256;

    AggregatorV3Interface internal dataFeed;
    uint256 constant public MIN_USD = 5 * 10**18;
    address payable immutable public owner;
    address[] public funders;
    mapping(address => uint256) public funderToFunded;

    constructor()  {
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        if(msg.sender != owner) revert FUNDME_NOT_AUTHORIZED();
        _;
    }

    function fund() public payable {
        if(msg.value.getConversionRateInUSD(dataFeed) < MIN_USD) revert FUNDME_BELOW_MINIMUM();
        funders.push(msg.sender);
        funderToFunded[msg.sender] = funderToFunded[msg.sender] + msg.value;
    }

    function withdraw() public payable onlyOwner {
        for(uint256 i = 0; i < funders.length; i++) {
            funderToFunded[funders[i]] = 0;
        }
        funders = new address[](0);
        (bool sent,) = owner.call{value: address(this).balance}("");
        if(!sent) revert FUNDME_FAILED_WITHDRAW();
    }

    function getConversionRateInUSD(uint256 _weiToConvert) external view returns (uint256) {
        return _weiToConvert.getConversionRateInUSD(dataFeed);
    }

    function getConversionRateInWEI(uint256 _usdToConvert) external view returns (uint256) {
        _usdToConvert *= 1e18;
        return _usdToConvert.getConversionRateInWEI(dataFeed);
    }

    function getPrice() external view returns (uint256) {
        return PriceFeed.getPrice(dataFeed);
    }


    receive() external payable { 
        fund();
    }

    fallback() external payable {
        fund();
    }
 }