module sll_32_2b (
    input [31:0] in,
    output [31:0] out
);

    assign out[1:0] = 2'b00;
    assign out[31:2] = in[29:0];
endmodule

// iverilog -o sll_32_2b -s sll_32_2b_tb -c .\sll_reqs.txt