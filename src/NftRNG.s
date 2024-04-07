// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "./BaseNft.sol";
import {GelatoVRFConsumerBase} from "./../lib/vrf-contracts/contracts/GelatoVRFConsumerBase.sol";

/**
preload URIs. minting is done via rng.
 */

contract NftRNG is BaseNft, GelatoVRFConsumerBase {

    constructor(string memory name, string memory symbol, string memory baseURI, address owner, uint256 maxSupply, uint256 maxPerMint, uint256 price, address operator) 
        BaseNft(name, symbol, owner, maxSupply, maxPerMint, price) GelatoVRFConsumerBase(operator) {

        baseTokenURI = baseURI;

        //pre-mint
        //mint();
    
        // payout split check: must add to 100
        if((creatorPayoutFactor + devPayoutFactor) != 1e18) revert("Invalid proportion");
    }


    /*//////////////////////////////////////////////////////////////
                                  VRF
    //////////////////////////////////////////////////////////////*/


    function _fulfillRandomness(bytes32 randomness, uint64 requestId, bytes memory data) internal override {
    }
    
// https://docs.gelato.network/web3-services/vrf/how-does-gelato-vrf-work
// https://github.com/gelatodigital/vrf-nft/blob/main/src/IceCreamNFT.sol

}
