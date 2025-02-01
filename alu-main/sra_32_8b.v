module sra_32_8b (
    input [31:0] in,
    output [31:0] out
);

    assign out[31:24] = in[7:0];
    assign out[23:0] = in[31:8];
endmodule


// iverilog -o sra_32_8b -s sra_32_8b_tb -c .\sra_reqs.txt