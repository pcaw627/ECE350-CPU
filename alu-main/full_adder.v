module full_adder(sum, cout, a, b, cin);
    input a, b, cin;
    output sum, cout;
    wire w1, w2, w3;

    // syntax: gate instance_name(output, input_1, input_2...)
    xor Sresult(sum, a, b, cin);
    and A_and_B(w1, a, b);
    and A_and_C(w2, a, cin);
    and B_and_C(w3, b, cin);
    or Cout(cout, w1, w2, w3);

endmodule

// iverilog -o full_adder -s full_adder_tb .\full_adder.v .\full_adder_tb.v
// vvp .\full_adder