// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {StorageExp} from "../src/StorageExp.sol";
import {HelperConfig} from "./01_HelperConfig.s.sol";

contract DeployStorageExp is Script {
    // should always have a run function.
    // the run function should be the only public/external function in the contract.
    function run() external returns (StorageExp) {
        address anvilOne = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        // deploy the contract
        vm.startBroadcast();
        StorageExp storageExperiment = new StorageExp(anvilOne);
        vm.stopBroadcast();
        return storageExperiment;
    }
}
