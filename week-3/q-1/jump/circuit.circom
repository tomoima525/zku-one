
pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/mimcsponge.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

/* A template to check if inputs are in the range */
template RangeUnit(units) {
  signal input x1;
  signal input y1;
  signal input x2;
  signal input y2;
  signal output out;

  signal diffX;
  diffX <== x1 - x2;
  signal diffY;
  diffY <== y1 - y2;

  component ltDist = LessThan(32);
  signal firstDistSquare;
  signal secondDistSquare;
  firstDistSquare <== diffX * diffX;
  secondDistSquare <== diffY * diffY;
  ltDist.in[0] <== firstDistSquare + secondDistSquare;
  ltDist.in[1] <== units * units + 1;
  out <== ltDist.out;
}

/*
    Prove: I know (x_a,y_a,x_b,y_b,x_c,y_c) such that:
    - (x_a - x_b)*y_c + (y_b - y_a)*x_c != x_a*y_b - x_b*y_a
    - (x_a-x_b)^2 + (y_a-y_b)^2 <= 10^2
    - (x_b-x_c)^2 + (y_b-y_c)^2 <= 10^2
    - MiMCSponge(x_a,y_a) = pubA
    - MiMCSponge(x_b,y_b) = pubB
    - MiMCSponge(x_c,y_c) = pubC
*/
template Main(units) {

    signal input x_a;
    signal input y_a;
    signal input x_b;
    signal input y_b;
    signal input x_c;
    signal input y_c;

    signal output pubA;
    signal output pubB;
    signal output pubC;

    /* check if ABC forms a triangle */

    signal left1;
    signal left2;
    signal right1;
    signal right2;
    left1 <== (x_a - x_b)*y_c; 
    left2 <== (y_b - y_a)*x_c;
    right1 <== x_a*y_b;
    right2 <== x_b*y_a;
    component isEqual = IsEqual();
    isEqual.in[0] <== left1 + left2;
    isEqual.in[1] <== right1 + right2;
    isEqual.out === 0;

    /* check (x_a-x_b)^2 + (y_a-y_b)^2 <= 10^2 */
    component rangeAB = RangeUnit(10);
    rangeAB.x1 <== x_a;
    rangeAB.y1 <== y_a;
    rangeAB.x2 <== x_b;
    rangeAB.y2 <== y_b;
    rangeAB.out === 1;

    /* check (x_b-x_c)^2 + (y_b-y_c)^2 <= 10^2 */
    component rangeBC = RangeUnit(10);
    rangeBC.x1 <== x_b;
    rangeBC.y1 <== y_b;
    rangeBC.x2 <== x_c;
    rangeBC.y2 <== y_c;
    rangeBC.out === 1;

    /* check 
     MiMCSponge(x_a,y_a) = pubA
     MiMCSponge(x_b,y_b) = pubB
     MiMCSponge(x_c,y_c) = pubC 

    220 = 2 * ceil(log_5 p), as specified by mimc paper, where
    p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
    */
    component mimcA = MiMCSponge(2, 220, 1);
    component mimcB = MiMCSponge(2, 220, 1);
    component mimcC = MiMCSponge(2, 220, 1);

    mimcA.ins[0] <== x_a;
    mimcA.ins[1] <== y_a;
    mimcA.k <== 0;
    mimcB.ins[0] <== x_b;
    mimcB.ins[1] <== y_b;
    mimcB.k <== 0;
    mimcC.ins[0] <== x_c;
    mimcC.ins[1] <== y_c;
    mimcC.k <== 0;

    pubA <== mimcA.outs[0];
    pubB <== mimcB.outs[0];
    pubC <== mimcC.outs[0];
}

component main = Main(10);