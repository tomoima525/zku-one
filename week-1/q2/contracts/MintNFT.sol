// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./TxMerkleTree.sol";

contract MintNFT is ERC721, ReentrancyGuard {
    using Counters for Counters.Counter;

    constructor() ERC721("Tomo", "TOMO") {}

    Counters.Counter private supplyCounter;

    TxMerkleTree merkleTree;

    function setMerkleTree(address merkleTreeAddress) public {
        merkleTree = TxMerkleTree(merkleTreeAddress);
    }

    /**
     * Mint NFT to address
     * This function interacts with Merkle Tree Contract.
     * It will create Merkle Tree using transaction Data
     */
    function mint(address to) public nonReentrant {
        require(to != address(0), "ERC721: mint to the zero address");
        _safeMint(msg.sender, totalSupply());

        // Add NFT transaction to MerkleTree
        merkleTree.addLeaf(
            msg.sender,
            to,
            totalSupply(),
            tokenURI(totalSupply())
        );

        // Increment counter
        supplyCounter.increment();
    }

    function totalSupply() public view returns (uint256) {
        return supplyCounter.current();
    }

    function tokenURI(uint256 tokenId)
        public
        pure
        override
        returns (string memory)
    {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "TomoNFT #',
                        toString(tokenId),
                        '", "description": "Hi!"}'
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    /**
     * Convert uint to string
     * Based on
     * https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol MIT license
     */
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
