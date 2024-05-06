// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {AggregatorV3Interface} from "chainlink/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceFeed} from "./PriceFeed.sol";

error FUNDME_NOT_AUTHORIZED();
error FUNDME_BELOW_MINIMUM();
error FUNDME_FAILED_WITHDRAW();

contract FundMe {
    using PriceFeed for uint256;

    AggregatorV3Interface internal s_dataFeed;
    uint256 public constant MIN_USD = 5 * 10 ** 18;
    address payable public immutable i_owner;
    address[] public s_funders;
    mapping(address => uint256) public s_funderToFunded;

    constructor(address _dataFeed) {
        s_dataFeed = AggregatorV3Interface(_dataFeed);
        i_owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FUNDME_NOT_AUTHORIZED();
        _;
    }

    function fund() public payable {
        if (msg.value.getConversionRateInUSD(s_dataFeed) < MIN_USD)
            revert FUNDME_BELOW_MINIMUM();
        s_funders.push(msg.sender);
        s_funderToFunded[msg.sender] = s_funderToFunded[msg.sender] + msg.value;
    }

    function withdraw() public payable onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 i = 0; i < fundersLength; ++i) {
            s_funderToFunded[s_funders[i]] = 0;
        }
        s_funders = new address[](0);
        (bool sent, ) = i_owner.call{value: address(this).balance}("");
        if (!sent) revert FUNDME_FAILED_WITHDRAW();
    }

    function getConversionRateInUSD(
        uint256 _weiToConvert
    ) external view returns (uint256) {
        return _weiToConvert.getConversionRateInUSD(s_dataFeed);
    }

    function getConversionRateInWEI(
        uint256 _usdToConvert
    ) external view returns (uint256) {
        _usdToConvert *= 1e18;
        return _usdToConvert.getConversionRateInWEI(s_dataFeed);
    }

    function getPrice() external view returns (uint256) {
        return PriceFeed.getPrice(s_dataFeed);
    }

    function getVersion() external view returns (uint256) {
        return s_dataFeed.version();
    }

    function getLatestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return s_dataFeed.latestRoundData();
    }

    // runs if msg.data is empty and ether is sent to contract
    receive() external payable {
        fund();
    }

    // runs if msg.data is not empty or if there is no recieve() function
    // can also recieve ether
    fallback() external payable {
        fund();
    }
}
