// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "chainlink/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceFeed {
    function getConversionRateInUSD(
        uint256 _value,
        AggregatorV3Interface _dataFeed
    ) internal view returns (uint256) {
        //  also price
        uint256 answer = getPrice(_dataFeed);
        return (_value * answer) / 1e18;
    }

    function getConversionRateInWEI(
        uint256 _value,
        AggregatorV3Interface _dataFeed
    ) internal view returns (uint256) {
        uint256 answer = getPrice(_dataFeed);
        return (_value * 1 ether) / answer;
    }

    function getPrice(
        AggregatorV3Interface _dataFeed
    ) internal view returns (uint256) {
        (
            ,
            /* uint80 roundID */
            int256 answer,
            ,
            ,

        ) = /*uint startedAt*/
            /*uint timeStamp*/
            // uint80 answeredInRound
            _dataFeed.latestRoundData();
        require(answer > 0, "Price is too low");
        return uint256(answer * 1e10);
    }
}
