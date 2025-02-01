module sra_32_4b (
    input [31:0] in,
    output [31:0] out
);

    assign out[31:28] = in[3:0];
    assign out[27:0] = in[31:4];
endmodule


// iverilog -o sra_32_4b -s sra_32_4b_tb -c .\sra_reqs.txt