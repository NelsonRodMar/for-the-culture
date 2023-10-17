// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";

contract GenerateTrustedRemote is Script {
    // Dead Address 0x000000000000000000000000000000000000dEaD
    address chain1; //
    address chain2; //
    address receiver;

    function run() public view {
        console.log("setTrustedRemoteAddress() for chain 1 :");
        console.logBytes(abi.encodePacked(address(chain2), address(chain1)));

        console.log("setTrustedRemoteAddress() for chain 2 : ");
        console.logBytes(abi.encodePacked(address(chain1), address(chain2)));

        console.log("Address to send in 32Bytes : ");
        console.logBytes32(bytes32(uint256(uint160(address(receiver)))));

        console.log("_adapterParams : ");
        console.logBytes(abi.encodePacked(uint16(1), uint256(200000)));
    }
}
