module half_adder(
    input a,
    input b,
    output sum,
    output cout
);
    xor x1(sum, a, b);
    and a1(cout, a, b);
endmodule