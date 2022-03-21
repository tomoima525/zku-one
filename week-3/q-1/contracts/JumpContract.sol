// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import "./Verifier.sol";

contract JumpContract {
    event Jumped(uint256 locA, uint256 locB, uint256 locC);

    /**
     * @dev Jump location move. A -> B -> C -> A
     */
    function jump(
        uint256[2] memory _a,
        uint256[2][2] memory _b,
        uint256[2] memory _c,
        uint256[3] memory _input
    ) public {
        uint256 _locA = _input[0];
        uint256 _locB = _input[1];
        uint256 _locC = _input[2];

        uint256[3] memory _proofInput = [_locA, _locB, _locC];

        require(
            Verifier.verifyJumpProof(_a, _b, _c, _proofInput),
            "Failed jump proof check"
        );

        emit Jumped(_locA, _locB, _locC);
    }
}
