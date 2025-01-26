module and_1(out, in1, in2);
    input in1, in2;
    output out;

    // syntax: gate instance_name(output, input_1, input_2...)
    and in1_and_in2(out, in1, in2);

endmodule

// iverilog -o and_1 -s and_1_tb .\and_1.v .\and_1_tb.v
// vvp .\and_1