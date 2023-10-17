// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/*
 /$$$$$$$$                        /$$$$$$$$ /$$                        /$$$$$$            /$$   /$$
| $$_____/                       |__  $$__/| $$                       /$$__  $$          | $$  | $$
| $$     /$$$$$$   /$$$$$$          | $$   | $$$$$$$   /$$$$$$       | $$  \__/ /$$   /$$| $$ /$$$$$$   /$$   /$$  /$$$$$$   /$$$$$$
| $$$$$ /$$__  $$ /$$__  $$         | $$   | $$__  $$ /$$__  $$      | $$      | $$  | $$| $$|_  $$_/  | $$  | $$ /$$__  $$ /$$__  $$
| $$__/| $$  \ $$| $$  \__/         | $$   | $$  \ $$| $$$$$$$$      | $$      | $$  | $$| $$  | $$    | $$  | $$| $$  \__/| $$$$$$$$
| $$   | $$  | $$| $$               | $$   | $$  | $$| $$_____/      | $$    $$| $$  | $$| $$  | $$ /$$| $$  | $$| $$      | $$_____/
| $$   |  $$$$$$/| $$               | $$   | $$  | $$|  $$$$$$$      |  $$$$$$/|  $$$$$$/| $$  |  $$$$/|  $$$$$$/| $$      |  $$$$$$$
|__/    \______/ |__/               |__/   |__/  |__/ \_______/       \______/  \______/ |__/   \___/   \______/ |__/       \_______/
FTC of FTX and SBF
*/

import {ONFT721} from "@layerzerolabs/contracts/token/onft721/ONFT721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

/// @title ForTheCulture
/// @notice An omnichain NFT that represents the crypto culture.
/// @author NelsonRodMar.lens
contract ForTheCulture is ONFT721 {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/


    uint256 public constant PRICE = 0.0022 ether; // 22 like the 22 Billion dollars of the generous billionaire SBF.

    /*//////////////////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/


    /// @param _layerZeroEndpoint The address of the LayerZero endpoint.
    /// @param _minGasToTransfer The minimum gas to transfer.
    constructor(uint256 _minGasToTransfer, address _layerZeroEndpoint)
        ONFT721("ForTheCulture", "FTC", _minGasToTransfer, _layerZeroEndpoint)
    {}


    /*//////////////////////////////////////////////////////////////////////////
                           PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/


    /// @notice Mint a part of the culture.
    function mint() public payable {
        require(msg.value >= PRICE, "ForTheCulture: insufficient funds");

        (bool success, ) = owner().call{value: msg.value}("");
        require(success, "ForTheCulture: transfer failed");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(msg.sender, tokenId);
    }

    /// @notice Mint multiple part of the culture.
    /// @param _amount The number of tokens to mint.
    function mint(uint256 _amount) public payable {
        require(msg.value >= _amount * PRICE, "ForTheCulture: insufficient funds");

        (bool success, ) = owner().call{value: msg.value}("");
        require(success, "ForTheCulture: transfer failed");

        uint256 tokenId;
        for(uint256 i = 0; i < _amount; i++) {
            tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();

            _safeMint(msg.sender, tokenId);
        }
    }

    /// @notice To burn a part of the crypto culture :'(
    /// @param _tokenId The token ID to burn
    function burn(uint256 _tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ForTheCulture: caller is not owner nor approved");
        _burn(_tokenId);
    }

    /// @notice Returns the URI for a given token ID.
    /// @param _tokenId The token ID.
    /// @return The URI.
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ForTheCulture: URI query for nonexistent token");

        return 'ar://eQzBoiTFZ47bPyhi699P8PCh5JwV34kJCoN5VVG4W4Q';
    }
}
