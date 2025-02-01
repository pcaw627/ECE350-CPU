module sra_32_2b (
    input [31:0] in,
    output [31:0] out
);

    // 1100101 -> 1111001
    // 0000111 -> 0000001
    assign out[31:30] = {in[31], in[31]};
    assign out[29:0] = in[31:2];
endmodule


// iverilog -o sra_32_2b -s sra_32_2b_tb -c .\sra_reqs.txt