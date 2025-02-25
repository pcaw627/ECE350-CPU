module and_64(out, in1, in2);
    input [63:0] in1, in2;
    output [63:0] out;

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
    and (out[32], in1[32], in2[32]);
    and (out[33], in1[33], in2[33]);
    and (out[34], in1[34], in2[34]);
    and (out[35], in1[35], in2[35]);
    and (out[36], in1[36], in2[36]);
    and (out[37], in1[37], in2[37]);
    and (out[38], in1[38], in2[38]);
    and (out[39], in1[39], in2[39]);
    and (out[40], in1[40], in2[40]);
    and (out[41], in1[41], in2[41]);
    and (out[42], in1[42], in2[42]);
    and (out[43], in1[43], in2[43]);
    and (out[44], in1[44], in2[44]);
    and (out[45], in1[45], in2[45]);
    and (out[46], in1[46], in2[46]);
    and (out[47], in1[47], in2[47]);
    and (out[48], in1[48], in2[48]);
    and (out[49], in1[49], in2[49]);
    and (out[50], in1[50], in2[50]);
    and (out[51], in1[51], in2[51]);
    and (out[52], in1[52], in2[52]);
    and (out[53], in1[53], in2[53]);
    and (out[54], in1[54], in2[54]);
    and (out[55], in1[55], in2[55]);
    and (out[56], in1[56], in2[56]);
    and (out[57], in1[57], in2[57]);
    and (out[58], in1[58], in2[58]);
    and (out[59], in1[59], in2[59]);
    and (out[60], in1[60], in2[60]);
    and (out[61], in1[61], in2[61]);
    and (out[62], in1[62], in2[62]);
    and (out[63], in1[63], in2[63]);


endmodule

// iverilog -o and_64 -s and_64_tb .\and_64.v .\and_64_tb.v
// vvp .\and_64