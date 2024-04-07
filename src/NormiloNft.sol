// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {ERC721} from "./../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Burnable} from "./../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {Ownable} from "./../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "./../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";

contract Normilo is ERC721Enumerable, ERC721Burnable, Ownable, Pausable {

    bytes32 public merkleRoot;
    
    uint256 public constant WAVE_1_MINT_CAP = 5;
    uint256 public constant WAVE_2_MINT_CAP = 3;
    uint256 public constant ALL_OTHERS_MINT_CAP = 1;

    // 09:00 EST -> 13:00 UTC -> 1712667600 UNIX
    uint256 public constant WAVE_1_START_TIME = 1712667600;
    uint256 public constant WAVE_2_START_TIME = WAVE_1_START_TIME + 1800;
    uint256 public constant WAVE_3_START_TIME = WAVE_2_START_TIME + 1800;
    uint256 public constant WAVE_4_START_TIME = WAVE_3_START_TIME + 1800;
    uint256 public constant WAVE_5_START_TIME = WAVE_4_START_TIME + 1800;
    uint256 public constant PUBLIC_START_TIME = WAVE_5_START_TIME + 3600;

    // 
    uint256 public immutable MAX_SUPPLY;
    uint256 public immutable MAX_PER_MINT;
    uint256 public immutable PRICE;
    
    string public baseTokenURI;

    // payout addresses 
    address public constant creatorAddress = 0x6F84Fa72Ca4554E0eEFcB9032e5A4F1FB41b726C;
    address public constant devAddress = 0xcBCc84766F2950CF867f42D766c43fB2D2Ba3256;
    // payout split
    uint256 public constant creatorPayoutFactor = 0.5 ether;
    uint256 public constant devPayoutFactor = 0.5 ether;


    event NftMinted(uint256 indexed id);

    constructor(string memory name, string memory symbol, address owner, uint256 maxSupply, uint256 maxPerMint, uint256 price, bytes32 root) 
        ERC721(name, symbol) Ownable(owner) {
        
        MAX_SUPPLY = maxSupply;
        MAX_PER_MINT = maxPerMint;
        PRICE = price;

        merkleRoot = root;

        _pause();

        // payout split check: must add to 100
        if((creatorPayoutFactor + devPayoutFactor) != 1e18) revert("Invalid proportion");
    }


    /*//////////////////////////////////////////////////////////////
                                BASEURI
    //////////////////////////////////////////////////////////////*/

    ///@dev to overwrite baseURI
    // lock this 
    function setBaseURI(string memory baseURI) public onlyOwner virtual {
        baseTokenURI = baseURI;
    }

    ///@dev overwrite the empty implementation in ERC721
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /*//////////////////////////////////////////////////////////////
                                  MINT
    //////////////////////////////////////////////////////////////*/

    function mint(address to, uint256 amount) public payable virtual whenNotPaused {
        // check that there is sufficient left to mint
        require(totalSupply() + amount <= MAX_SUPPLY, "Supply Exceeded");

        require(amount <= MAX_PER_MINT, "Exceeds batch limit");
        require(msg.value >= (amount * PRICE), "Invalid payment");

        // batch mint        
        uint id = totalSupply();
        for (uint256 i = 0; i < amount; i++) {

            _safeMint(to, id);    
            ++id;

            emit NftMinted(id);
        }
    }


    /*//////////////////////////////////////////////////////////////
                                WITHDRAW
    //////////////////////////////////////////////////////////////*/

    function withdrawAll() external payable virtual onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        
        // calc.
        uint256 creatorPayout = (creatorPayoutFactor * balance) / 1e18; 
        uint256 devPayout = (devPayoutFactor * balance) / 1e18;

        _withdraw(devAddress, devPayout);
        _withdraw(creatorAddress, creatorPayout);
    }

    function _withdraw(address to, uint256 amount) internal {
        
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }


    /*//////////////////////////////////////////////////////////////
                                  USER
    //////////////////////////////////////////////////////////////*/

    
    // return array of tokenIds owned by an address
    function ownerHoldings(address owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);

        uint256[] memory tokenIds = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }

        return tokenIds;
    }


    /*//////////////////////////////////////////////////////////////
                                OVERRIDE
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }


    //note: check paused works correctly w/ update
    function _update(address to, uint256 tokenId, address auth) internal whenNotPaused virtual override(ERC721, ERC721Enumerable) returns (address) {
       return ERC721Enumerable._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 amount) internal virtual override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._increaseBalance(account, amount);
    }

    /*//////////////////////////////////////////////////////////////
                                PAUSABLE
    //////////////////////////////////////////////////////////////*/

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }


}
