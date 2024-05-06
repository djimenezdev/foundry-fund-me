// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/02_DeployFundMe.s.sol";

error FUNDME_BELOW_MINIMUM();
error FUNDME_NOT_AUTHORIZED();
error FUNDME_FAILED_WITHDRAW();

contract FundMeTest is Test {
    DeployFundMe deployFundMe;
    FundMe fundMe;
    uint256 sepoliaFork;

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

    /* function testCanSelectFork() public {
        // select the fork
        vm.selectFork(sepoliaFork);
        assertEq(vm.activeFork(), sepoliaFork);
    } */

    function testMinimumUSD() external view {
        uint256 minUSD = 5e18;
        assertEq(fundMe.MIN_USD(), minUSD);
    }

    function testOwner() external view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function test_RevertIf_NotEnoughETH() external {
        vm.expectRevert(FUNDME_BELOW_MINIMUM.selector);
        fundMe.fund();
    }

    function testFund() external payable {
        vm.startPrank(USER);
        fundMe.fund{value: AMOUNT}();
        fundMe.fund{value: AMOUNT}();
        vm.stopPrank();
        assertEq(fundMe.s_funders(0), USER);
        assertEq(fundMe.s_funderToFunded(USER), AMOUNT * 2);
        assertEq(address(fundMe).balance, AMOUNT * 2);
    }

    function test_RevertIf_NotAuthorizedToWithdraw() external {
        vm.prank(USER);
        vm.expectRevert(FUNDME_NOT_AUTHORIZED.selector);
        fundMe.withdraw();
    }

    function testWithdraw() external {
        fundMe.fund{value: AMOUNT}();
        fundMe.fund{value: AMOUNT}();
        uint256 ownerCurrentBalance = address(msg.sender).balance;
        uint256 contractCurrentBalance = address(fundMe).balance;
        vm.prank(address(msg.sender));
        fundMe.withdraw();
        assertEq(address(fundMe).balance, 0);
        assertEq(
            address(msg.sender).balance,
            ownerCurrentBalance + contractCurrentBalance
        );
    }

    /* function test_RevertIf_FailedWithdraw() external {
        console.log("Balance: %d", address(fundMe).balance);
        vm.prank(address(msg.sender));
        vm.expectRevert(FUNDME_FAILED_WITHDRAW.selector);
        fundMe.withdraw();
    } */

    function testPriceFeedVersion() external view {
        /* vm.selectFork(sepoliaFork);
        // address priceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); */
        uint256 version = fundMe.getVersion();
        console.log("Price: %d", version);
        assertEq(version, 4);
    }

    function testFeedPrice() external view {
        uint256 price = fundMe.getPrice();
        console.log("Price: %d", price);
        assertEq(price, 2000e18);
    }

    function testLatestRoundData() external view {
        (uint80 roundId, int256 answer, , , ) = fundMe.getLatestRoundData();
        console.log("RoundID: %d", roundId);
        console.log("Answer: %d", uint256(answer));
        assertEq(roundId, 1);
        assertEq(answer, 2000e8);
    }

    function testConversionRateInUSD() external view {
        uint256 rate = fundMe.getConversionRateInUSD(AMOUNT);
        console.log("Rate: %d", rate);
        assertEq(rate, 2e22);
    }

    function testConversionRateInWEI() external view {
        uint256 rate = fundMe.getConversionRateInWEI(2000);
        console.log("Rate: %d", rate);
        assertEq(rate, 1e18);
    }

    function testReceive() external {
        vm.startPrank(USER);
        address payable fundMeAddress = payable(address(fundMe));
        fundMeAddress.call{value: AMOUNT}("");
        assertEq(fundMe.s_funders(0), USER);
        assertEq(fundMe.s_funderToFunded(USER), AMOUNT);
        assertEq(address(fundMe).balance, AMOUNT);
        vm.stopPrank();
    }

    function testFallback() external {
        vm.startPrank(USER);
        address payable fundMeAddress = payable(address(fundMe));
        fundMeAddress.call{value: AMOUNT}("0x1c8aff95");
        assertEq(fundMe.s_funders(0), USER);
        assertEq(fundMe.s_funderToFunded(USER), AMOUNT);
        assertEq(address(fundMe).balance, AMOUNT);
        vm.stopPrank();
    }
}
