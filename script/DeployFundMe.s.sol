// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() public returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!
        //address priceFeed = helperConfig.getConfigByChainId(block.chainid).priceFeed;
        address ethUsdpriceFeed = helperConfig.activeNetworkConfig();


        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdpriceFeed);
        vm.stopBroadcast();
        return fundMe;
        
    }
}