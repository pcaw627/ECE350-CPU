module full_adder(out1, out2, in1, in2, in3);
    input in1, in2, in3;
    output out1, out2;
    wire w1, w2, w3;

    // syntax: gate instance_name(output, input_1, input_2...)
    xor Sresult(out1, in1, in2, in3);
    and A_and_B(w1, in1, in2);
    and A_and_C(w2, in1, in3);
    and B_and_C(w3, in2, in3);
    or Cout(out2, w1, w2, w3);

endmodule

// iverilog -o full_adder -s full_adder_tb .\full_adder.v .\full_adder_tb.v
// vvp .\full_adder