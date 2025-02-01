module not_1(out, in);
    input in;
    output out;

    // syntax: gate instance_name(output, input_1, input_2...)
    not (out, in);

endmodule

// iverilog -o not_1 -s not_1_tb .\not_1.v .\not_1_tb.v
// vvp .\not_1