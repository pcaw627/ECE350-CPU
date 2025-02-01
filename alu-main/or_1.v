module or_1(out, in1, in2);
    input in1, in2;
    output out;

    // syntax: gate instance_name(output, input_1, input_2...)
    or in1_and_in2(out, in1, in2);

endmodule

// iverilog -o or_1 -s or_1_tb .\or_1.v .\or_1_tb.v
// vvp .\or_1