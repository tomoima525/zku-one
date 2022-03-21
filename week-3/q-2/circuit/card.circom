pragma circom 2.0.3;

include "circomlib/poseidon.circom";

/*
Prove: I know (identity, card number, suite) such that:
- A hash of (identity, card number, suite) matches a circom-generated hash

Private input: identity, card number
Public input: suite
Public output: Card Hash
*/
template Main() {

    signal input identity;
    signal input cardNumber;
    signal input suite;

    signal output cardHash;

    component poseidon = Poseidon(3);

    poseidon.inputs[0] <== identity;
    poseidon.inputs[1] <== cardNumber;
    poseidon.inputs[2] <== suite;
    cardHash <== poseidon.out;
}

component main {public [suite] } = Main();


/* INPUT = {
  "identity": 1,
  "cardNumber": 10,
  "suite": 1
} */