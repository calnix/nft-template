// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Merkle {


    function constructTree(address[] memory members) public pure returns (bytes32 root, bytes32[][] memory tree) {
        require(members.length != 0);
        
        // Determine tree height: keep dividing no. of leaves by 2 till you get 1
        uint256 height = 0;
        {
            uint256 n = members.length; 
            while (n != 0) {
                // if (n == 1) n = 0; else n = (n + 1)/2;
                // (n + 1) to deal w/ odd numbers: 6 --> 3: (treated as 4) --> 2 --> 1
                n = n == 1 ? 0 : (n + 1) / 2;  
                ++height;
            }
        }
        tree = new bytes32[][](height);     // 2-D array: bytes32[][height]tree. top-level is height.

        // The first layer of the tree contains the leaf nodes, which are hashes of each member and claim amount.
        bytes32[] memory nodes = tree[0] = new bytes32[](members.length);

        for (uint256 i = 0; i < members.length; ++i) {
            // Leaf hashes are inverted to prevent second preimage attacks.
            nodes[i] = ~keccak256(abi.encode(members[i]));
        }

        // build intermediate layers and finally root
        // loop thru layers
        for (uint256 h = 1; h < height; ++h) {
            
            // calc no.f of hashes for that layer
            uint256 nHashes = (nodes.length + 1) / 2;            
            bytes32[] memory hashes = new bytes32[](nHashes);   
            
            // nodes.length = total no. of members
            for (uint256 i = 0; i < nodes.length; i += 2) {
                
                bytes32 a = nodes[i];

                // Tree is sparse. Missing nodes will have a value of 0.
                bytes32 b = i + 1 < nodes.length ? nodes[i + 1] : bytes32(0);
                // Siblings are always hashed in sorted order.
                hashes[i / 2] = keccak256(a > b ? abi.encode(b, a) : abi.encode(a, b));    
            }

            tree[h] = nodes = hashes;
        }
        
        // Note the tree root is at the bottom.
        root = tree[height - 1][0];
    }


    // Given a merkle tree and a member index (leaf node index), generate a proof.
    // The proof is simply the list of sibling nodes/hashes leading up to the root.
    function createProof(uint256 memberIndex, bytes32[][] memory tree) external pure returns(bytes32[] memory) {
        
        uint256 height = tree.length;
        uint256 nodeIndex = memberIndex;

        // list of intermediate hashes, less the initial leaf
        bytes32[] memory proof = new bytes32[](height - 1);

        //cycle thru the layers
        for(uint256 h = 0; h < proof.length; ++h){
            // is the index even? if even, look forward, else look backward 
            uint256 sibilingIndex = nodeIndex % 2 == 0 ? nodeIndex + 1 : nodeIndex - 1;

            if(sibilingIndex < tree[h].length){        // will terminate the root
                proof[h] = tree[h][sibilingIndex];
            } 

            nodeIndex /= 2;     // div by 2, rounded down. index for the next layer.
        }

        return proof;
    }


    /**
     * @notice Given a leaf hash in a merkle tree and a list of sibling hashes/nodes, attempt to arrive at the root hash
     * @param leaf Merkle leaf to be verified
     * @param merkleRoot Root for a specific block
     * @param siblings Sibling hashes to calculate the merkle root
     * @return True: If provided leaf and sibling hashes compute the stored root.
     */ 
    function verify(bytes32 leaf, bytes32 merkleRoot, bytes32[] calldata siblings) public pure returns (bool) {
        // In a sparse tree, empty leaves have a value of 0, so don't allow 0 as input.
        require(leaf != 0, 'invalid leaf value');

        bytes32 node = leaf;

        for (uint256 i = 0; i < siblings.length; ++i) {
            bytes32 sibling = siblings[i]; 
            
            // Siblings are always hashed in sorted order
            node = keccak256(node > sibling ? abi.encode(sibling, node) : abi.encode(node, sibling));
        }
        return node == merkleRoot;
    }
}