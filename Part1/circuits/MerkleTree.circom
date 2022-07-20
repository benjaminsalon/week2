pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template DepthArray(d) { // compute the d-1 depth of the merkle tree with given the d depth of the merkle tree
    signal input depthD[2**d];
    signal output depthDMinusOne[2**(d-1)];
    component hashes[2**(d-1)];
    for (var j =0; j < 2**(d-1); j++){
        hashes[j] = Poseidon(2);
        hashes[j].inputs[0] <-- depthD[j*2];
        hashes[j].inputs[1] <-- depthD[j*2+1];
        depthDMinusOne[j] <-- hashes[j].out;
    }
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    component components[n];
    components[0] = DepthArray(n);
    components[0].depthD <-- leaves;
    var i;
    for (i = 1; i < n; i++) {
        components[i] = DepthArray(n-i);
        components[i].depthD <-- components[i-1].depthDMinusOne;
    }
    root <-- components[n-1].depthDMinusOne[0];
    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
}

/// from https://github.com/zku-cohort-3/week5/blob/master/2_verify_merkle/merkle.circom
// if s == 0 returns [in[0], in[1]]
// if s == 1 returns [in[1], in[0]]
template DualMux() {
    signal input in[2];
    signal input s;
    signal output out[2]; 

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hashes[n];
    component selectors[n];
    var currentLeaf = leaf;
    for (var p = 0; p<n; p++) {
        hashes[p] = Poseidon(2);
        selectors[p] = DualMux();
        selectors[p].in[0] <== currentLeaf;
        selectors[p].in[1] <== path_elements[p];
        selectors[p].s <== path_index[p];

        hashes[p].inputs[0] <== selectors[p].out[0];
        hashes[p].inputs[1] <== selectors[p].out[1];
        currentLeaf = hashes[p].out;
    }
    root <== currentLeaf;

}