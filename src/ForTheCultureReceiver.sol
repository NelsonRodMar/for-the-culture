// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ONFT721} from "@layerzerolabs/contracts/token/onft721/ONFT721.sol";

/// @title ForTheCultureReceiver
/// @notice The receiver of an omnichain NFT that represents the culture.
/// @author NelsonRodMar.lens
contract ForTheCultureReceiver is ONFT721 {

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


    /// @notice To burn a part of the crypto culture :'(
    /// @param tokenId The token ID.
    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ForTheCultureReceiver: caller is not owner nor approved");
        _burn(tokenId);
    }


    /// @notice Returns the URI for a given token ID.
    /// @param _tokenId The token ID.
    /// @return The URI.
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ForTheCultureReceiver: URI query for nonexistent token");

        return 'ar://eQzBoiTFZ47bPyhi699P8PCh5JwV34kJCoN5VVG4W4Q';
    }
}
