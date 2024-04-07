// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Kanji is ERC721, Ownable {
    using Strings for uint256;

    uint256 public constant SALE_MAX = 100;
    uint256 public constant PER_MINT = 1;
    uint256 public constant KANJI_PRICE = 0.5 ether;
    address public PAYOUT_ADDRESS;

    mapping(string => bool) private _nonces;
    mapping(address => bool) private _minters;

    string private _tokenBaseURI = "https://nft-api.flyingnobita.workers.dev/api/metadata/";

    address private _signerAddress;
    string private signPrefix = "Signed for Kanji Minting:";

    uint256 public totalSupply;
    bool public saleLive = true;

    constructor() ERC721("Kanji", "KANJI") {
        PAYOUT_ADDRESS = msg.sender;
        _signerAddress = msg.sender;
    }

    function verifyTransaction(address sender, uint256 amount, bytes calldata signature, string calldata nonce) private view returns (bool) {
        bytes32 hash = keccak256(
            abi.encodePacked(signPrefix, sender, amount, nonce, address(this))
        );
        
        address recoveredAddress = ECDSA.recover(hash, signature);
        return _signerAddress == recoveredAddress;
    }

    function purchase(uint256 amount, bytes calldata signature, string calldata nonce) external payable {
        require(saleLive, "Kanji: Sale Closed");
        require(amount <= PER_MINT, "Kanji: Amount Exceeded");
        require(totalSupply + amount <= SALE_MAX, "Kanji: Max Minted");
        require(!_nonces[nonce], "Kanji: Secret Used");
        require(_minters[msg.sender] == false, "Kanji: Address already minted");
        require(
            verifyTransaction(msg.sender, amount, signature, nonce),
            "Kanji: Contract Mint Not Allowed"
        );

        require(KANJI_PRICE * amount <= msg.value, "Kanji: Insufficient ETH");

        _nonces[nonce] = true;
        _minters[msg.sender] = true;

        for (uint256 i = 1; i <= amount; i++) {
            _mint(msg.sender, totalSupply + i);
        }

        totalSupply += amount;
    }

    function toggleNonce(string calldata nonce) external onlyOwner {
        _nonces[nonce] = !_nonces[nonce];
    }

    function withdraw() external onlyOwner {
        payable(PAYOUT_ADDRESS).transfer(address(this).balance);
    }

    function toggleSale() external onlyOwner {
        saleLive = !saleLive;
    }

    function setSignerAddress(address addr) external onlyOwner {
        _signerAddress = addr;
    }

    function setBaseURI(string calldata uri) external onlyOwner {
        _tokenBaseURI = uri;
    }

}

//https://github.com/flyingnobita/nft-kanji-solidity/blob/main/contracts/Kanji.sol