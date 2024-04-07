# ....



## References

1. cryptopunks: https://etherscan.io/address/0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb#code
2. penguinds: https://etherscan.io/address/0xbd3531da5cf5857e7cfaa92426877b022e612cf8#readContract
3. apymon: https://vscode.blockscan.com/ethereum/0x9C008A22D71B6182029b694B0311486e4C0e53DB


## VRF

1. https://medium.com/coinmonks/unpredictable-randomness-to-nft-minting-with-chainlink-vrf-v2-f6ecd43052cc
2. https://github.com/Ak-prog-50/VRF_minting_contract/blob/main/contracts/VRFMinting.sol


## OZv5 ERC721

does not have _exists, which you will need to check if the random tokenId is already taken. 
implement this manually.

```solidity
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
```

## Signatures vs Merkls + Bitmaps

1. https://medium.com/donkeverse/hardcore-gas-savings-in-nft-minting-part-2-signatures-vs-merkle-trees-917c43c59b07
2. https://medium.com/donkeverse/hardcore-gas-savings-in-nft-minting-part-3-save-30-000-in-presale-gas-c945406e89f0

### ECDSA

- Using ECDSA for whitelist: https://medium.com/@ItsCuzzo/using-signatures-ecdsa-for-nft-whitelists-ba0a4d070e92
- https://docs.alchemy.com/docs/how-to-create-an-off-chain-nft-allowlist
- https://dev.to/rounakbanik/tutorial-digital-signatures-nft-allowlists-eeb


TLDR: Use signatures for presale and airdrops with over 127 participants. Otherwise, use Merkle trees.



:: URI and rarity
1. dummy base uri, then change after minting
2. load actual uri, then use vrf for minting

:: whitelist


:: tiered structure


:: snapshot


