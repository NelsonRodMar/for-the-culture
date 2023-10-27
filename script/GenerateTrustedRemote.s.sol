// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";

contract GenerateTrustedRemote is Script {
    // Dead Address 0x000000000000000000000000000000000000dEaD
    address chain1 = 0xB1379C5041c5cA4C222388429Ed5EFA22C9BBdE7; // Base
    address chain2;
    //
    address receiver = 0x770569f85346B971114e11E4Bb5F7aC776673469;

    function run() public view {
        console.log("setTrustedRemoteAddress() for chain 1 :");
        console.logBytes(abi.encodePacked(address(chain2), address(chain1)));

        console.log("setTrustedRemoteAddress() for chain 2 : ");
        console.logBytes(abi.encodePacked(address(chain1), address(chain2)));

        console.log("Address to send in Bytes : ");
        console.logBytes(abi.encodePacked(receiver));

        console.log("_adapterParams : ");
        console.logBytes(abi.encodePacked(uint16(1), uint256(200000)));
    }
}
