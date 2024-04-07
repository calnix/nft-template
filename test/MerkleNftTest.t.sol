// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdStorage, StdStorage} from "forge-std/Test.sol";
import {Merkle} from "./Merkle.sol";


abstract contract StateZero is Test {

    // contracts
    Merkle public merkle;

    //priv. addresses
    address public owner;
    address public deployer;

    // users
    address public userA;
    address public userB;
    address public userC;

    uint256 public votesA;
    uint256 public votesB;
    uint256 public votesC;

    function setUp() public virtual {
        
        // users
        userA = makeAddr("userA");
        userB = makeAddr("userB");
        userC = makeAddr("userC");

        owner = makeAddr("admin");
        deployer = makeAddr("deployer");




        // contracts
        merkle = new Merkle();

    }

    function generateRoot() public returns (bytes32, bytes32[][] memory) {
        address[] memory members = new address[](3);
        members[0] = userA;
        members[1] = userB;
        members[2] = userC;

        (bytes32 root, bytes32[][] memory tree) = merkle.constructTree(members);

        return (root, tree);
    }
}


//Note: Post-deployment sanity checks
contract StateZeroTest is StateZero {

    function testMerkleTree() public {
        console2.log("Test merkle tree functions");

        // generate root
        (bytes32 root, bytes32[][] memory tree) = generateRoot();

        // gen. proofs
        bytes32[] memory proof = merkle.createProof(0, tree);

        //test proofs
        bytes32 leaf = ~keccak256(abi.encode(userA));

        bool isVerified = merkle.verify(leaf, root, proof);

        assertEq(isVerified, true);
    }




}