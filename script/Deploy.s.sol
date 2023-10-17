// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ForTheCulture} from "../src/ForTheCulture.sol";
import {ForTheCultureReceiver} from "../src/ForTheCultureReceiver.sol";
import {console2 as console} from "forge-std/console2.sol";

// Base 0xb6319cC6c8c27A8F5dAF0dD3DF91EA35C4720dd7
contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        ForTheCulture forTheCulture = new ForTheCulture(
            150000, // _minGasToTransfer
            0x000000000000000000000000000000000000dEaD //address _layerZeroEndpoint
        );
        console.log("ForTheCulture address: ", address(forTheCulture));
        vm.stopBroadcast();
    }
}
