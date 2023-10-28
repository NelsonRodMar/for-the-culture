// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";

import {ForTheCultureReceiver} from "../src/ForTheCultureReceiver.sol";


contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        ForTheCultureReceiver forTheCultureReceiver = new ForTheCultureReceiver(
            150000, // _minGasToTransfer
            0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7 //address _layerZeroEndpoint
        );
        console.log("ForTheCultureReceiver address: ", address(forTheCultureReceiver));
        vm.stopBroadcast();
    }
}
