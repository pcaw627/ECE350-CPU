module and_32(out, in1, in2);
    input [31:0] in1, in2;
    output [31:0] out;

    // syntax: gate instance_name(output, input_1, input_2...)
    and (out[0], in1[0], in2[0]);
    and (out[1], in1[1], in2[1]);
    and (out[2], in1[2], in2[2]);
    and (out[3], in1[3], in2[3]);
    and (out[4], in1[4], in2[4]);
    and (out[5], in1[5], in2[5]);
    and (out[6], in1[6], in2[6]);
    and (out[7], in1[7], in2[7]);
    and (out[8], in1[8], in2[8]);
    and (out[9], in1[9], in2[9]);
    and (out[10], in1[10], in2[10]);
    and (out[11], in1[11], in2[11]);
    and (out[12], in1[12], in2[12]);
    and (out[13], in1[13], in2[13]);
    and (out[14], in1[14], in2[14]);
    and (out[15], in1[15], in2[15]);
    and (out[16], in1[16], in2[16]);
    and (out[17], in1[17], in2[17]);
    and (out[18], in1[18], in2[18]);
    and (out[19], in1[19], in2[19]);
    and (out[20], in1[20], in2[20]);
    and (out[21], in1[21], in2[21]);
    and (out[22], in1[22], in2[22]);
    and (out[23], in1[23], in2[23]);
    and (out[24], in1[24], in2[24]);
    and (out[25], in1[25], in2[25]);
    and (out[26], in1[26], in2[26]);
    and (out[27], in1[27], in2[27]);
    and (out[28], in1[28], in2[28]);
    and (out[29], in1[29], in2[29]);
    and (out[30], in1[30], in2[30]);
    and (out[31], in1[31], in2[31]);


endmodule

// iverilog -o and_32 -s and_32_tb .\and_32.v .\and_32_tb.v
// vvp .\and_32