module full_adder(S, Cout, A, B, Cin);
    input A, B, Cin;
    output S, Cout;
    wire w1, w2, w3;

    // syntax: gate instance_name(output, input_1, input_2...)
    xor Sresult(S, A, B, Cin);
    and A_and_B(w1, A, B);
    and A_and_C(w2, A, Cin);
    and B_and_C(w3, B, Cin);
    or (Cout, w1, w2, w3);

endmodule

// iverilog -o full_adder -s full_adder_tb .\full_adder.v .\full_adder_tb.v
// vvp .\full_adder