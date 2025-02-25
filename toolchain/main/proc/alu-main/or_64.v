module or_64(out, in1, in2);
    input [63:0] in1, in2;
    output [63:0] out;

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
    or (out[32], in1[32], in2[32]);
    or (out[33], in1[33], in2[33]);
    or (out[34], in1[34], in2[34]);
    or (out[35], in1[35], in2[35]);
    or (out[36], in1[36], in2[36]);
    or (out[37], in1[37], in2[37]);
    or (out[38], in1[38], in2[38]);
    or (out[39], in1[39], in2[39]);
    or (out[40], in1[40], in2[40]);
    or (out[41], in1[41], in2[41]);
    or (out[42], in1[42], in2[42]);
    or (out[43], in1[43], in2[43]);
    or (out[44], in1[44], in2[44]);
    or (out[45], in1[45], in2[45]);
    or (out[46], in1[46], in2[46]);
    or (out[47], in1[47], in2[47]);
    or (out[48], in1[48], in2[48]);
    or (out[49], in1[49], in2[49]);
    or (out[50], in1[50], in2[50]);
    or (out[51], in1[51], in2[51]);
    or (out[52], in1[52], in2[52]);
    or (out[53], in1[53], in2[53]);
    or (out[54], in1[54], in2[54]);
    or (out[55], in1[55], in2[55]);
    or (out[56], in1[56], in2[56]);
    or (out[57], in1[57], in2[57]);
    or (out[58], in1[58], in2[58]);
    or (out[59], in1[59], in2[59]);
    or (out[60], in1[60], in2[60]);
    or (out[61], in1[61], in2[61]);
    or (out[62], in1[62], in2[62]);
    or (out[63], in1[63], in2[63]);



endmodule

// iverilog -o or_64 -s or_64_tb .\or_64.v .\or_64_tb.v
// vvp .\or_64