// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract TxMerkleTree {
    bytes32[] public hashes;

    // Array of leaves
    bytes32[] public leaves;

    /**
     * Add Leaf and create Merkle Tree.
     * Merkle Tree is re-created every time new leaf is added
     */
    function addLeaf(
        address sender,
        address receiver,
        uint256 tokenId,
        string memory tokenURI
    ) public {
        // Reset Merkle tree
        delete hashes;

        // Add hashed leaves to array
        leaves.push(
            keccak256(abi.encodePacked(sender, receiver, tokenId, tokenURI))
        );

        // Add leaves to hashes to generate Merkle tree
        for (uint256 i = 0; i < leaves.length; i++) {
            hashes.push(keccak256(abi.encodePacked(leaves[i])));
        }
        uint256 n = leaves.length;
        uint256 offset = 0;

        while (n > 1) {
            // create a hash using pairs of nodes. If nodes are odd,
            // then the last node in the for-loop will be hashed with itself
            for (uint256 i = 0; i < n; i += 2) {
                // the last node when the length is odd
                if (i == n - 1) {
                    hashes.push(
                        keccak256(abi.encodePacked(hashes[offset + i]))
                    );
                } else {
                    hashes.push(
                        keccak256(
                            abi.encodePacked(
                                hashes[offset + i],
                                hashes[offset + i + 1]
                            )
                        )
                    );
                }
            }
            offset += n;
            // Repeat creating hashes while it reaches to 1
            if (n % 2 == 0) {
                n = n / 2;
            } else {
                // odd
                n = (n + 1) / 2;
            }
        }
    }

    function getMerkleRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }

    function getLeavesLength() public view returns (uint256) {
        return leaves.length;
    }
}
