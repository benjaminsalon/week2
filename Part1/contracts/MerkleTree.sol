//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform PoseidonT3.Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    
    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        uint i;
        for (i=0; i<8;i++){
            hashes.push(0);
        }
        for (i=8; i<12;i++){
            hashes.push(PoseidonT3.poseidon([hashes[2*(i-8)],hashes[2*(i-8)+1]]));
        }
        for(i=12; i<14; i++){
            hashes.push(PoseidonT3.poseidon([hashes[8+2*(i-12)],hashes[8+2*(i-12)+1]]));
        }
        hashes.push(PoseidonT3.poseidon([hashes[12],hashes[13]]));
        root = hashes[14];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index++] = hashedLeaf;
        uint i;
        for (i=8; i<12;i++){
            hashes.push(PoseidonT3.poseidon([hashes[2*(i-8)],hashes[2*(i-8)+1]]));
        }
        for(i=12; i<14; i++){
            hashes.push(PoseidonT3.poseidon([hashes[8+2*(i-12)],hashes[8+2*(i-12)+1]]));
        }
        hashes.push(PoseidonT3.poseidon([hashes[12],hashes[13]]));
        root = hashes[14];
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input);
    }
}
