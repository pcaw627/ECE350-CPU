module sra_32_1b (
    input [31:0] in,
    output [31:0] out
);

    // 1100101 -> 1110010
    // out is padded to left (msb) with the original msb of the in
    assign out[31] = in[31];
    assign out[30:0] = in[31:1];
endmodule


// iverilog -o sra_32_1b -s sra_32_1b_tb -c .\sra_reqs.txt