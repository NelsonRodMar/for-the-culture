// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";

import {ForTheCulture} from "../src/ForTheCulture.sol";
import {ForTheCultureReceiver} from "../src/ForTheCultureReceiver.sol";

import {LZEndpointMock} from "./mocks/LZEndpointMock.sol";

import {ICommonOFT} from "@layerzerolabs/contracts/token/oft/v2/interfaces/ICommonOFT.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BridgeTest is Test {
    ForTheCulture private forTheCulture;
    ForTheCultureReceiver private forTheCultureReceiver;
    LZEndpointMock private lzEndpointBase;
    LZEndpointMock private lzEndpointScroll;

    Receiver owner; // Owner of the contract
    Receiver addr1; // Address 1

    uint256 public mintPrice;

    uint16 public constant BASE_CHAIN_ID = 184;
    uint16 public constant SCROLL_CHAIN_ID = 214;
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant BATCH_SIZE_LIMIT = 300;
    uint256 public constant MIN_GAS_TRANSFER = 150000;
    bytes public constant DEFAULT_ADAPTER_PARAMS = abi.encodePacked(uint16(1), uint256(200000));

    function setUp() public {
        // Create owner and addr1 as Receiver so they can receive NFTs
        owner = new Receiver();
        addr1 = new Receiver();
        // Sending ETH to the contract
        vm.deal(address(owner), 100 ether);
        vm.deal(address(addr1), 100 ether);

        // Create lzEndpointMock
        vm.startPrank(address(owner));
        lzEndpointBase = new LZEndpointMock(BASE_CHAIN_ID);
        lzEndpointScroll = new LZEndpointMock(SCROLL_CHAIN_ID);

        assertEq(lzEndpointBase.getChainId(), BASE_CHAIN_ID);
        assertEq(lzEndpointScroll.getChainId(), SCROLL_CHAIN_ID);

        // Deploy contract
        forTheCulture = new ForTheCulture(
            MIN_GAS_TRANSFER, // _minGasToTransfer
            address(lzEndpointBase) //address _layerZeroEndpoint for Base
        );
        mintPrice = forTheCulture.PRICE();

        forTheCultureReceiver = new ForTheCultureReceiver(
            MIN_GAS_TRANSFER, // _minGasToTransfer
            address(lzEndpointScroll) //address _layerZeroEndpoint for Scroll
        );

        // wire the lz endpoints to guide msgs back and forth
        lzEndpointBase.setDestLzEndpoint(address(forTheCultureReceiver), address(lzEndpointScroll));
        lzEndpointScroll.setDestLzEndpoint(address(forTheCulture), address(lzEndpointBase));

        // set each contracts source address so it can send to each other
        forTheCulture.setTrustedRemote(
            SCROLL_CHAIN_ID, abi.encodePacked(address(forTheCultureReceiver), address(forTheCulture))
        );
        forTheCultureReceiver.setTrustedRemote(
            BASE_CHAIN_ID, abi.encodePacked(address(forTheCulture), address(forTheCultureReceiver))
        );

        // set batch size limit
        forTheCulture.setDstChainIdToBatchLimit(SCROLL_CHAIN_ID, BATCH_SIZE_LIMIT);
        forTheCultureReceiver.setDstChainIdToBatchLimit(BASE_CHAIN_ID, BATCH_SIZE_LIMIT);

        // set min dst gas for swap
        forTheCulture.setMinDstGas(SCROLL_CHAIN_ID, 1, MIN_GAS_TRANSFER);
        forTheCultureReceiver.setMinDstGas(BASE_CHAIN_ID, 1, MIN_GAS_TRANSFER);

        //forTheCulture.setMinGasToTransferAndStore(400000);
        //forTheCultureReceiver.setMinGasToTransferAndStore(400000);

        vm.stopPrank();
    }

    //@notice sendFrom() your own tokens
    function testSendFrom() public {
        uint256 tokenId = 0; // First token id

        vm.startPrank(address(owner));
        forTheCulture.mint{value: mintPrice}();

        assertEq(forTheCulture.ownerOf(tokenId), address(owner), "owner of token id 0 should be owner");

        vm.expectRevert("ERC721: invalid token ID");
        forTheCultureReceiver.ownerOf(tokenId);

        // can transfer token on srcChain as regular erC721
        forTheCulture.transferFrom(address(owner), address(addr1), tokenId);
        assertEq(forTheCulture.ownerOf(tokenId), address(addr1), "owner of token id 0 should be addr1");
        vm.stopPrank();

        // approve the proxy to swap your token
        vm.startPrank(address(addr1));
        forTheCulture.approve(address(forTheCulture), tokenId);

        // estimate nativeFees
        (uint256 nativeFee, uint256 zroFee) = forTheCulture.estimateSendFee(
            SCROLL_CHAIN_ID, abi.encode(address(this)), tokenId, false, DEFAULT_ADAPTER_PARAMS
        );

        // send token to other chain
        forTheCulture.sendFrom{value: nativeFee}(
            address(addr1),
            SCROLL_CHAIN_ID,
            abi.encodePacked(address(addr1)),
            tokenId,
            payable(address(addr1)),
            DEAD_ADDRESS,
            DEFAULT_ADAPTER_PARAMS
        );
        // wait a few blocks
        vm.warp(block.timestamp + 100);

        // Token is sequestrate on the contract
        assertEq(forTheCulture.ownerOf(tokenId), address(forTheCulture), "owner of token id 0 should be forTheCulture");

        // Token received on dst chain
        assertEq(forTheCultureReceiver.ownerOf(tokenId), address(addr1), "owner of token id 0 should be addr1");

        // Resend on base chain to owner
        (uint256 nativeFee2, uint256 zroFee2) = forTheCultureReceiver.estimateSendFee(
            BASE_CHAIN_ID, abi.encode(address(owner)), tokenId, false, DEFAULT_ADAPTER_PARAMS
        );

        forTheCultureReceiver.approve(address(forTheCultureReceiver), tokenId);
        forTheCultureReceiver.sendFrom{value: nativeFee2}(
            address(addr1),
            BASE_CHAIN_ID,
            abi.encodePacked(address(addr1)),
            tokenId,
            payable(address(addr1)),
            DEAD_ADDRESS,
            DEFAULT_ADAPTER_PARAMS
        );

        // Token is sequestrate on the contract
        assertEq(
            forTheCultureReceiver.ownerOf(tokenId),
            address(forTheCultureReceiver),
            "owner of token id 0 should be forTheCultureReceiver"
        );

        // Token received on dst chain
        assertEq(forTheCulture.ownerOf(tokenId), address(addr1), "owner of token id 0 should be addr1");
    }

    //@notice sendFrom() reverts if not owner on non proxy chain
    function testSendFromRevert() public {
        uint256 tokenId = 0; // First token id

        vm.startPrank(address(owner));
        forTheCulture.mint{value: mintPrice}();

        forTheCulture.approve(address(forTheCulture), tokenId);

        // estimate nativeFees
        (uint256 nativeFee, uint256 zroFee) = forTheCulture.estimateSendFee(
            SCROLL_CHAIN_ID, abi.encode(address(this)), tokenId, false, DEFAULT_ADAPTER_PARAMS
        );

        // send token to other chain
        forTheCulture.sendFrom{value: nativeFee}(
            address(owner),
            SCROLL_CHAIN_ID,
            abi.encodePacked(address(owner)),
            tokenId,
            payable(address(owner)),
            DEAD_ADDRESS,
            DEFAULT_ADAPTER_PARAMS
        );

        // token received on the dst chain
        assertEq(forTheCultureReceiver.ownerOf(tokenId), address(owner), "owner of token id 0 should be owner");

        // reverts because other address does not own it
        vm.expectRevert("ONFT721: send from incorrect owner");
        forTheCultureReceiver.sendFrom{value: nativeFee}(
            address(addr1),
            BASE_CHAIN_ID,
            abi.encodePacked(address(addr1)),
            tokenId,
            payable(address(addr1)),
            DEAD_ADDRESS,
            DEFAULT_ADAPTER_PARAMS
        );
    }

    //@notice sendFrom() on behalf of other user
    function testSendFromBehalfOtherUser() public {
        uint256 tokenId = 0; // First token id

        vm.startPrank(address(owner));
        forTheCulture.mint{value: mintPrice}();
        forTheCulture.approve(address(forTheCulture), tokenId);

        // estimate nativeFees
        (uint256 nativeFee, uint256 zroFee) = forTheCulture.estimateSendFee(
            SCROLL_CHAIN_ID, abi.encode(address(this)), tokenId, false, DEFAULT_ADAPTER_PARAMS
        );

        // send token to other chain
        forTheCulture.sendFrom{value: nativeFee}(
            address(owner),
            SCROLL_CHAIN_ID,
            abi.encodePacked(address(owner)),
            tokenId,
            payable(address(owner)),
            DEAD_ADDRESS,
            DEFAULT_ADAPTER_PARAMS
        );
        assertEq(forTheCultureReceiver.ownerOf(tokenId), address(owner), "owner of token id 0 should be owner");

        // Send to base chain to another address than the owner
        forTheCultureReceiver.approve(address(forTheCultureReceiver), tokenId);
        (nativeFee, zroFee) = forTheCultureReceiver.estimateSendFee(
            BASE_CHAIN_ID, abi.encode(address(addr1)), tokenId, false, DEFAULT_ADAPTER_PARAMS
        );
        forTheCultureReceiver.sendFrom{value: nativeFee}(
            address(owner),
            BASE_CHAIN_ID,
            abi.encodePacked(address(addr1)),
            tokenId,
            payable(address(owner)),
            DEAD_ADDRESS,
            DEFAULT_ADAPTER_PARAMS
        );

        assertEq(forTheCulture.ownerOf(tokenId), address(addr1), "owner of token id 0 should be addr1");
    }

    //@notice sendFrom() reverts if contract is approved, but not the sending user
    function testSendFromRevertsIfContractIsApprovedButNotSendingUser() public {
        uint256 tokenId = 0; // First token id

        vm.startPrank(address(owner));
        forTheCulture.mint{value: mintPrice}();
        forTheCulture.approve(address(forTheCulture), tokenId);

        // estimate nativeFees
        (uint256 nativeFee, uint256 zroFee) = forTheCulture.estimateSendFee(
            SCROLL_CHAIN_ID, abi.encode(address(this)), tokenId, false, DEFAULT_ADAPTER_PARAMS
        );

        // send token to other chain
        forTheCulture.sendFrom{value: nativeFee}(
            address(owner),
            SCROLL_CHAIN_ID,
            abi.encodePacked(address(owner)),
            tokenId,
            payable(address(owner)),
            DEAD_ADDRESS,
            DEFAULT_ADAPTER_PARAMS
        );
        assertEq(forTheCultureReceiver.ownerOf(tokenId), address(owner), "owner of token id 0 should be owner");

        // Approve the user to send the token
        forTheCultureReceiver.approve(address(forTheCultureReceiver), tokenId);

        // reverts because other address does not own it
        (uint256 nativeFee2, uint256 zroFee2) = forTheCultureReceiver.estimateSendFee(
            BASE_CHAIN_ID, abi.encode(address(addr1)), tokenId, false, DEFAULT_ADAPTER_PARAMS
        );
        vm.startPrank(address(addr1));
        vm.expectRevert("ONFT721: send caller is not owner nor approved");
        forTheCultureReceiver.sendFrom{value: nativeFee2}(
            address(owner),
            BASE_CHAIN_ID,
            abi.encodePacked(address(addr1)),
            tokenId,
            payable(address(addr1)),
            DEAD_ADDRESS,
            DEFAULT_ADAPTER_PARAMS
        );
    }

    //@notice sendFrom() reverts if sender does not own token
    function testSendFromRevertsIfSendNotOwnToken() public {
        uint256 tokenIdA = 0; // First token id
        uint256 tokenIdB = 1; // First token id

        vm.startPrank(address(owner));
        forTheCulture.mint{value: mintPrice}();

        vm.startPrank(address(addr1));
        forTheCulture.mint{value: mintPrice}();

        vm.startPrank(address(owner));
        forTheCulture.setApprovalForAll(address(forTheCulture), true);

        vm.startPrank(address(addr1));
        (uint256 nativeFee, uint256 zroFee) = forTheCulture.estimateSendFee(
            SCROLL_CHAIN_ID, abi.encode(address(addr1)), tokenIdA, false, DEFAULT_ADAPTER_PARAMS
        );
        vm.expectRevert("ONFT721: send caller is not owner nor approved");
        forTheCulture.sendFrom{value: nativeFee}(
            address(addr1),
            SCROLL_CHAIN_ID,
            abi.encodePacked(address(addr1)),
            tokenIdA,
            payable(address(addr1)),
            DEAD_ADDRESS,
            DEFAULT_ADAPTER_PARAMS
        );
    }

    //@notice sendBactchFrom() test
    function testSendBatchFrom() public {
        uint256[4] memory tokenIds = [uint256(0), 1, 2, 3];

        vm.startPrank(address(owner));
        uint256 totalPriceToPaid = mintPrice * tokenIds.length;
        forTheCulture.mint{value: totalPriceToPaid}(tokenIds.length);

        assertEq(forTheCulture.balanceOf(address(owner)), tokenIds.length, "not all the onft have been minted");

        forTheCulture.setApprovalForAll(address(forTheCulture), true);

        // TODO Finish if useful
    }

    receive() external payable {}
}

contract Receiver is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}
}
