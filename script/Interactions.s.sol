//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "src/FundMe.sol";

contract FundFundMe is Script {
    uint256 FUND_VALUE = 0.01 ether;
    address mostRecentDeloy;

    function fundFundMe(address _recentDeploy) public {
        vm.startBroadcast();
        FundMe(payable(_recentDeploy)).fund{value: FUND_VALUE}();
        console.log("Funded FundMe with %s", FUND_VALUE);
        vm.stopBroadcast();
    }

    function run() external {
        mostRecentDeloy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentDeloy);
    }
}

contract WithdrawFundMe is Script {
    uint256 FUND_VALUE = 0.01 ether;
    address mostRecentDeloy;

    function withdrawFundMe(address _recentDeploy) public {
        vm.startBroadcast();
        FundMe(payable(_recentDeploy)).withdraw();
        console.log("Withdraw from FundMe %s", FUND_VALUE);
        vm.stopBroadcast();
    }

    function run() external {
        mostRecentDeloy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentDeloy);
    }
}
