module sll_32_16b (
    input [31:0] in,
    output [31:0] out
);

    assign out[15:0] = 16'b0000000000000000;
    assign out[31:16] = in[15:0];
endmodule
