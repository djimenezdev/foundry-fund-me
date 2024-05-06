// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {StorageExp} from "src/StorageExp.sol";
import {DeployStorageExp} from "script/03_DeployStorageExp.s.sol";

contract FundMeTest is Test {
    StorageExp storageExp;
    DeployStorageExp deployStorageExp;

    function setUp() external {
        deployStorageExp = new DeployStorageExp();
        storageExp = deployStorageExp.run();
    }

    function test_arrayLength() external view {
        uint256 length = storageExp.getLengthYul();
        console.log("Length: ", length);
        assertEq(length, 5);
    }

    function test_valueAtIndex() external view {
        uint256 value = storageExp.getValue(2);
        console.log("Value at index 2: ", value);
        assertEq(value, 3);
    }

    function test_mappingValue() external view {
        address addressKey = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint256 value = storageExp.getMappingValue(addressKey);
        console.log("Value for address: ", value);
        assertEq(value, 5);
    }
}
