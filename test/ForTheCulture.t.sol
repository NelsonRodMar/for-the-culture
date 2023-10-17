// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";

import {ForTheCulture} from "../src/ForTheCulture.sol";
import {ForTheCultureReceiver} from "../src/ForTheCultureReceiver.sol";

import {LZEndpointMock} from "./mocks/LZEndpointMock.sol";

import {ICommonOFT} from "@layerzerolabs/contracts/token/oft/v2/interfaces/ICommonOFT.sol";

contract BridgeTest is Test {
    ForTheCulture private forTheCulture;
    ForTheCultureReceiver private forTheCultureReceiver;
    LZEndpointMock private lzEndpointBase;
    LZEndpointMock private lzEndpointOptimism;

    uint16 public constant BASE_CHAIN_ID = 184;
    uint16 public constant OPTIMISM_CHAIN_ID = 111;
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant BATCH_SIZE_LIMIT = 300;
    uint256 public constant MIN_GAS_TRANSFER = 150000;


    function setUp() public {
        //vm.createSelectFork(vm.envString("FOUNDRY_ETH_RPC_URL"));
        // Create lzEndpointMock
        lzEndpointBase = new LZEndpointMock(BASE_CHAIN_ID);
        lzEndpointOptimism = new LZEndpointMock(OPTIMISM_CHAIN_ID);

        assertEq(lzEndpointBase.getChainId(), BASE_CHAIN_ID);
        assertEq(lzEndpointOptimism.getChainId(), OPTIMISM_CHAIN_ID);

        // Deploy contract
        forTheCulture = new ForTheCulture(
            MIN_GAS_TRANSFER, // _minGasToTransfer
            address(lzEndpointBase) //address _layerZeroEndpoint for Base
        );

        forTheCultureReceiver = new ForTheCultureReceiver(
            MIN_GAS_TRANSFER, // _minGasToTransfer
            address(lzEndpointOptimism) //address _layerZeroEndpoint for Optimism
        );


        // wire the lz endpoints to guide msgs back and forth
        lzEndpointBase.setDestLzEndpoint(address(forTheCultureReceiver), address(lzEndpointOptimism));
        lzEndpointOptimism.setDestLzEndpoint(address(forTheCulture), address(lzEndpointBase));

        // set each contracts source address so it can send to each other
        forTheCulture.setTrustedRemote(
            OPTIMISM_CHAIN_ID, abi.encodePacked(address(forTheCultureReceiver), address(forTheCulture))
        );
        forTheCultureReceiver.setTrustedRemote(
            BASE_CHAIN_ID, abi.encodePacked(address(forTheCulture), address(forTheCultureReceiver))
        );

        // set batch size limit
        forTheCulture.setDstChainIdToBatchLimit(OPTIMISM_CHAIN_ID, BATCH_SIZE_LIMIT);
        forTheCultureReceiver.setDstChainIdToBatchLimit(BASE_CHAIN_ID, BATCH_SIZE_LIMIT);


        // set min dst gas for swap
        forTheCulture.setMinDstGas(OPTIMISM_CHAIN_ID, 1, MIN_GAS_TRANSFER);
        forTheCultureReceiver.setMinDstGas(BASE_CHAIN_ID, 1, MIN_GAS_TRANSFER);
    }

    function testBridgeNFT() public {
        // TODO
    }

    function testMintNFT() public {
        // TODO
    }

    receive() external payable {}
}
