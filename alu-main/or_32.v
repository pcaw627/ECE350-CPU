module or_32(out, in1, in2);
    input [31:0] in1, in2;
    output [31:0] out;

    // syntax: gate instance_name(output, input_1, input_2...)
    or (out[0], in1[0], in2[0]);
    or (out[1], in1[1], in2[1]);
    or (out[2], in1[2], in2[2]);
    or (out[3], in1[3], in2[3]);
    or (out[4], in1[4], in2[4]);
    or (out[5], in1[5], in2[5]);
    or (out[6], in1[6], in2[6]);
    or (out[7], in1[7], in2[7]);
    or (out[8], in1[8], in2[8]);
    or (out[9], in1[9], in2[9]);
    or (out[10], in1[10], in2[10]);
    or (out[11], in1[11], in2[11]);
    or (out[12], in1[12], in2[12]);
    or (out[13], in1[13], in2[13]);
    or (out[14], in1[14], in2[14]);
    or (out[15], in1[15], in2[15]);
    or (out[16], in1[16], in2[16]);
    or (out[17], in1[17], in2[17]);
    or (out[18], in1[18], in2[18]);
    or (out[19], in1[19], in2[19]);
    or (out[20], in1[20], in2[20]);
    or (out[21], in1[21], in2[21]);
    or (out[22], in1[22], in2[22]);
    or (out[23], in1[23], in2[23]);
    or (out[24], in1[24], in2[24]);
    or (out[25], in1[25], in2[25]);
    or (out[26], in1[26], in2[26]);
    or (out[27], in1[27], in2[27]);
    or (out[28], in1[28], in2[28]);
    or (out[29], in1[29], in2[29]);
    or (out[30], in1[30], in2[30]);
    or (out[31], in1[31], in2[31]);


endmodule

// iverilog -o or_32 -s or_32_tb .\or_32.v .\or_32_tb.v
// vvp .\or_32