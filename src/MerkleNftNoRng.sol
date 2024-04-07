// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "./BaseNft.sol";
import {MerkleProof} from "./../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

/**
post load URIs. minting is done sequentially.
uri are randmonly loaded to ipfs.
uri is revealed after minting

 */

contract MerkleNftNoRng is BaseNft{

    bytes32 public merkleRoot;

    
    uint256 public immutable WAVE_1_MINT_CAP = 5;
    uint256 public immutable WAVE_2_MINT_CAP = 3;
    uint256 public immutable ALL_OTHERS_MINT_CAP = 1;

    // 09:00 EST -> 13:00 UTC -> 1712667600 UNIX
    uint256 public immutable WAVE_1_START_TIME = 1712667600;
    uint256 public immutable WAVE_2_START_TIME = WAVE_1_START_TIME + 1800;
    uint256 public immutable WAVE_3_START_TIME = WAVE_2_START_TIME + 1800;
    uint256 public immutable WAVE_4_START_TIME = WAVE_3_START_TIME + 1800;
    uint256 public immutable WAVE_5_START_TIME = WAVE_4_START_TIME + 1800;
    uint256 public immutable PUBLIC_START_TIME = WAVE_5_START_TIME + 3600;

    constructor(string memory name, string memory symbol, address owner, uint256 maxSupply, uint256 maxPerMint, uint256 price) 
        BaseNft(name, symbol, owner, maxSupply, maxPerMint, price) {

        //pre-mint
        //mint();
    
        // payout split check: must add to 100
        if((creatorPayoutFactor + devPayoutFactor) != 1e18) revert("Invalid proportion");
    }

    function setMerkleRoots(bytes32 firstMerkle, bytes32 secondMerkle) external onlyOwner {
        MERKLE_ROOT_1_100 = firstMerkle;
        MERKLE_ROOT_101_1000 = secondMerkle;
    }

    function mint(uint256 amount, uint256 wave, bytes32[] calldata merkleProof) external payable whenNotPaused {
        require(amount > 0, "Invalid amount");
        require(wave <= 0, "Invalid amount");

        bytes32 node = keccak256(abi.encodePacked(msg.sender, wave));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "Invalid proof");          
        
        // wave 1: 1-100 holders
        if (wave == 1){
            require(block.timestamp >= WAVE_1_START_TIME, "Invalid wave");
            require(amount <= WAVE_1_MINT_CAP, "Exceeded cap");
        }

        // wave 2: 101-1000 holders
        if (wave == 2){
            require(block.timestamp >= WAVE_2_START_TIME, "Invalid wave");
            require(amount <= WAVE_2_MINT_CAP, "Exceeded cap");
        }

        // wave 3: 1001-2000 holders
        if (wave == 3){
            require(block.timestamp >= WAVE_3_START_TIME, "Invalid wave");
            require(amount <= ALL_OTHERS_MINT_CAP, "Exceeded cap");
        }

        // wave 4: 2001-3000 holders
        if (wave == 4){
            require(block.timestamp >= WAVE_4_START_TIME, "Invalid wave");
            require(amount <= ALL_OTHERS_MINT_CAP, "Exceeded cap");
        }

        // wave 5: 2001-3000 holders
        if (wave == 5){
            require(block.timestamp >= WAVE_5_START_TIME, "Invalid wave");
            require(amount <= ALL_OTHERS_MINT_CAP, "Exceeded cap");
        }

        BaseNft.mint(msg.sender, amount);
    }

}


/**
1    1-100 holder:
     09:00 EST -> 13:00 UTC -> 1712667600 UNIX
    
2    101-1000 holder:
     09:30 EST -> 13:30 UTC -> 1712669400 UNIX
    
3    1001-2000 holder:
     10:00 EST -> 14:00 UTC -> 1712671200 UNIX
    
4    2001-3000 holder:
     10:30 EST -> 14:30 UTC -> 1712673000 UNIX
    
5    3001-remaining holder: 
     11:00 EST -> 15:00 UTC -> 1712674800 UNIX
    
    Public
    12:00 EST -> 16:00 UTC -> 1712678400 UNIX

    rounds increment by 1800, except the last. last increment is 3600.


lock setTokenURI. one-way lock. can set as many time until lock.
 */