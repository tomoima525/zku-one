pragma circom 2.0.3;

include "node_modules/circomlib/circuits/mimcsponge.circom";


// Pattern 1. Generate Merkle root with pre-hashed leaves
// depth of the tree starts from 1
template MerkleRootByHashedLeaves(depth) {
   signal input leaves[2**(depth - 1)];

   signal output out;

   // All nodes in the tree
   component nodes[2**depth - 1];

   // hash all nodes first
   for(var i = 0; i < 2**(depth - 1); i++) {
      nodes[i] = MiMCSponge(1,220,1);
      nodes[i].ins[0] <== leaves[i];
      nodes[i].k <== 0;
   }

   // calculte merkle root
   // E.g. if the depth is 4
   // second depth
   // nodes[8] = hashOf(nodes[0], nodes[1])
   // nodes[9] = hashOf(nodes[2], nodes[3])
   // ...
   // third depth
   // nodes[12] = hashOf(nodes[8], nodes[9]) 
   // nodes[13] = hashOf(nodes[10], nodes[11]) 
   // fourth depth = merkel root
   // nodes[14] = hashOf(nodes[12], nodes[13]) 
   for(var j = 0; j < 2**depth - 2; j = j+2) {
      var parentNode = j/2 + 2**(depth - 1);
      nodes[parentNode] = MiMCSponge(2,220,1);
      nodes[parentNode].ins[0] <== nodes[j].outs[0];
      nodes[parentNode].ins[1] <== nodes[j+1].outs[0];
      nodes[parentNode].k <== 0; 
   }

   // the last one in the nodes is Merkle root
   out <== nodes[2**depth - 2].outs[0];
 
}

// Pattern2. Generate Merkle root with leaves
template MerkleRoot(depth) {
   signal input leaves[2**(depth - 1)];

   signal output out;

   // The number of hash can be calculated as
   // (The number of all nodes in the tree) - (the number of leaves)
   // = (2^depth - 1) - 2^(depth - 1)
   var hashSize = 2**depth - 1 - 2**(depth - 1);
   component hashes[hashSize];

   // create hashes for the first parent nodes from leaves
   for(var j = 0; j < 2**(depth - 1); j = j+2) {
      var parentNode = j/2;
      
      hashes[parentNode] = MiMCSponge(2,220,1);
      hashes[parentNode].ins[0] <== leaves[j];
      hashes[parentNode].ins[1] <== leaves[j+1];
      hashes[parentNode].k <== 0; 
   } 
   
   // calculate the rest of nodes. 
   for(var k = 0; k < hashSize - 1; k = k + 2) {
      // We need the offset of first parent nodes
      var parentNode = k/2 + 2**(depth - 2);

      hashes[parentNode] = MiMCSponge(2,220,1);
      hashes[parentNode].ins[0] <== hashes[k].outs[0];
      hashes[parentNode].ins[1] <== hashes[k+1].outs[0];
      hashes[parentNode].k <== 0; 
   }

   // the last one in the nodes is Merkle root
   out <== hashes[hashSize - 1].outs[0];
 
}

component main { public [leaves] } = MerkleRoot(4);