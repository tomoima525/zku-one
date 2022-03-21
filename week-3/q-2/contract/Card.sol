// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
import "./IVerifier.sol";

contract CardContract {
    IVerifier verifier;

    mapping(uint256 => address) pickedCards;

    constructor(address verifierAddress) {
        verifier = IVerifier(verifierAddress);
    }

    function _verify(
        uint256 cardHash,
        uint256 suite,
        uint256[8] calldata proof
    ) internal view returns (bool) {
        return
            verifier.verifyProof(
                [proof[0], proof[1]],
                [[proof[2], proof[3]], [proof[4], proof[5]]],
                [proof[6], proof[7]],
                [suite, cardHash]
            );
    }

    /// @dev Commit card
    function commitCard(
        address playerAddress,
        uint256 cardHash,
        uint256 suite,
        uint256[8] calldata proof
    ) public {
        // prevent picking up the same card
        require(
            pickedCards[cardHash] != playerAddress,
            "Player cannot pick the same card"
        );

        // Check commited card is valid without the actual data of the card
        require(_verify(cardHash, suite, proof), "Not verified");

        // Once verified, store the card data
        pickedCards[cardHash] = playerAddress;
    }
}
