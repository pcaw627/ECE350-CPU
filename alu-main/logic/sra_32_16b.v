module sra_32_16b (
    input [31:0] in,
    output [31:0] out
);

    assign out[31:16] = in[15:0];
    assign out[15:0] = in[31:16];
endmodule


// iverilog -o sra_32_16b -s sra_32_16b_tb -c .\sra_reqs.txt