// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./01_HelperConfig.s.sol";

contract DeployFundMe is Script {
    // should always have a run function.
    // the run function should be the only public/external function in the contract.
    function run() external returns (FundMe) {
        // anything config related should run before the broadcast unless its a state change that needs to be made on the deployment chain
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.activeNetworkConfig();
        // deploy the contract
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
