module sll_32_1b (
    input [31:0] in,
    output [31:0] out
);

    // 1100101 -> 1001010
    assign out[0] = 0;
    assign out[31:1] = in[30:0];
endmodule


// iverilog -o sll_32_1b -s sll_32_tb -c .\sll_reqs.txt