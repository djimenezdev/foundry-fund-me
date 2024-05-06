// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/02_DeployFundMe.s.sol";
import {FundFundMe} from "script/Interactions.s.sol";

error FUNDME_BELOW_MINIMUM();
error FUNDME_NOT_AUTHORIZED();
error FUNDME_FAILED_WITHDRAW();

contract FundMeTestIntegration is Test {
    DeployFundMe deployFundMe;
    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 USER_BALANCE = 30e18; // 30 ether

    uint256 AMOUNT = 10e18; // 10 ether. Which is above USD minimum

    function setUp() external {
        vm.deal(USER, USER_BALANCE);
        // string memory url = vm.envString("SEPOLIA_PRC_URL");
        // address priceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // sepoliaFork = vm.createFork(url);
    }

    function testUserCanFund() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        address funder = fundMe.s_funders(0);
        assertEq(funder, msg.sender);
    }
}
